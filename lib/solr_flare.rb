class SolrFlare
  SOLRFLARE_ROOT= RAILS_ROOT
  
  def self.get_model_instance(class_name)
    class_name = class_name.to_s
    unless @classes
      #initialise the classes map
      @classes = []
      ObjectSpace.each_object(Class){|model| @classes << model.to_s}
    end
    if @classes.include?(class_name)
      if (instance = eval(class_name))
        return instance
      end
    end
    return nil
  end
  
  def self.define_index(defined_on, block)
    index = self::Index.new(defined_on)
    block.call(index)
    self.indexes = self.indexes + [index]
  end
  
  def self.update_index_proc
    self.method(:reindex_instance)
  end
  
  def self.before_destroy_closure(id)
    @instances_to_send ||= {}
    proc{ |instance|
      @instances_to_send[id] = instance
    }
  end
  
  def self.after_destroy_closure(id)
    proc{ |instance|
      unless @instances_to_send[id].empty?
        @instances_to_send[id].each do |doc_instance|
          self.reindex_instance(doc_instance)
        end
        @instances_to_send[id]=nil
      end
    }
  end
  
  def self.search(options={})
    options[:wt] = 'xml'
    options[:fl] = 'model_name, id'
    options[:q] = '*:*' if (options[:q].try(:strip) || '').size == 0
    if model_name = options[:model_name]
      model_name = model_name.join(' | ') if model_name.is_a?(Array)
      options[:q] +=" model_name: #{model_name}"
      options.delete(:model_name)
    end
    options[:rows] ||= "10"
    options[:start] ||= '0'
    puts "q= #{options[:q].inspect}"
    response = self.solr.select(options)
    return self::Result.new(response,options[:rows].to_i)
  end
  
  ##
  # Queues all instances of the supplied classes for indexing. This is a batch job.. reading in all instances in order to queue them. 
  # NOT EFFICIENT IN THE SLIGHTEST. There must be a better way of doing this.
  #
  def self.reindex_all(classes=nil, priority=3, ignore_connected=true)
    this_proc = proc do |this_class|
      this_class.find_in_batches do |batch|
        batch.each do |entry|
          puts "Reindexing #{entry.class.to_s}::#{entry.id}"
          reindex_instance(entry,priority)
        end
      end
    end
    if classes
      if classes.is_a?(Array)
        classes.each do |this_class|
          this_proc.call(this_class)
        end
      else
        this_proc.call(classes)
      end
    end
  end
  
  def self.reindex_instance(instance, priority=5)
    MiddleMan.worker(:solr_flare_worker).enq_reindex_document(:args => {:id => instance.id, :model_name => instance.class.to_s}, :priority=> priority, :job_key => build_document_id(instance))
  end
  
  def self.action_indexing(id, model_name)
    instance = get_model_instance(model_name).find(id)
    unless (document_instances = map_instance_to_document_instances(instance)).empty?
      document_instances.each do |doc_instance|
        build_documents(id, model_name).each do |document|
          solr.update(solr_flare.solr.message.add(document, :commitWithin => 10))
        end
      end
    end
  end
  
  protected
  
  def self.solr
    @solr || RSolr.connect(:url=>self.config.full_solr_url)
  end
  def self.solr=(solr)
    @solr=solr
  end
  
  def self.build_document_id(instance)
    "#{instance.id}_#{instance.class.to_s}"
  end
  
  def self.build_documents(instance)
    data = []
    indexes.each do |index|
      this_data = index.build_document(instance)
      this_data[:id] = build_document_id(instance)
      data << this_data 
    end
    data.compact
  end
  
  def self.config
    @config || self::SolrFlareConfig.new("#{SOLRFLARE_ROOT}/config/solr_flare")
  end
  def self.config=(config)
    @config=config
  end
  
  def self.indexes
    @indexes||[]
  end
  def self.indexes=(indexes)
    @indexes=indexes
  end
  
  def self.map_instance_to_document_instances(instance)
    return_array = []
    indexes.each do |index|
      return_array += index.map_instance_to_document_instances(instance)
    end
    return_array.compact
  end
end
