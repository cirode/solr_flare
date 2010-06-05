class SolrFlare
  SOLRFLARE_ROOT= RAILS_ROOT
  
  def self.get_instance()
    unless @instance
      @instance = self.new
    end
    return @instance
  end
  
  def get_model_instance(class_name)
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
  
  def define_index(defined_on, block)
    index = self.class::Index.new(defined_on)
    block.call(index)
    self.indexes = self.indexes + [index]
  end
  
  def update_index_proc
    self.method(:reindex_instance)
  end
  
  def before_destroy_closure(id)
    @instances_to_send ||= {}
    proc{ |instance|
      @instances_to_send[id] = map_instance_to_document_instances(instance)
    }
  end
  
  def after_destroy_closure(id)
    proc{ |instance|
      unless @instances_to_send[id].empty?
        @instances_to_send[id].each do |doc_instance|
          MiddleMan.worker(:solr_flare_worker).enq_reindex_document(:args => {:id => doc_instance.id, :model_name => doc_instance.class.to_s}, :job_key => build_document_id(doc_instance))
        end
        @instances_to_send[id]=nil
      end
    }
  end
  
  def search(options={})
    options[:wt] = 'xml'
    options[:fl] = 'model_name, id'
    options[:q] = '*:*' if (options[:q].try(:strip) || '').size == 0
    if model_name = options[:model_name]
      model_name = model_name.join(' | ') if model_name.is_a?(Array)
      options[:q] +=" model_name: #{model_name}"
      options.delete(:model_name)
    end
    options[:rows] ||= '10'
    options[:start] ||= '0'
    puts "q= #{options[:q].inspect}"
    response = @solr.select(options)
    return self.class::Result.new(response)
  end
  
  def reindex_all(classes=nil, priority=3, ignore_connected=true)
    this_proc = proc do |this_class|
      unless ignore_connected
        #IF we need to re-index classes that rely on this class as well then it will take a while longer..
        this_class.find_in_batches do |batch|
          batch.each do |entry|
            puts "Reindexing #{entry.class.to_s}::#{entry.id}"
            reindex_instance(entry,priority)
          end
        end
      else
        #.. however we can do a really quick database-only way if we do not care about connected entries (usual case)
        ActiveRecord::Base.connection.execute("insert into index_queue_entries (instance_id, model_name, priority) select id, '#{this_class.to_s}',#{priority} from `#{this_class.table_name}`")
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
  
  def reindex_instance(instance, priority=5)
    unless (document_instances = map_instance_to_document_instances(instance)).empty?
      document_instances.each do |doc_instance|
        MiddleMan.worker(:solr_flare_worker).enq_reindex_document(:args => {:id => doc_instance.id, :model_name => doc_instance.class.to_s}, :job_key => build_document_id(doc_instance)) 
      end
    end
  end
  
  def build_documents(id, model_name)
    instance = get_model_instance(model_name).find(id)
    data = []
    indexes.each do |index|
      this_data = index.build_document(instance)
      this_data[:id] = build_document_id(instance)
      data << this_data
    end
    data.compact
  end
  
  def build_document_id(instance)
    "#{instance.id}_#{instance.class.to_s}"
  end
  
  attr_accessor :solr
  
  protected
  
  attr_accessor :config, :indexes
  
  def initialize(*args)
    super(*args)
    self.config = SolrFlare::SolrFlareConfig.new("#{SOLRFLARE_ROOT}/config/solr_flare")
    self.solr = RSolr.connect :url=>config.full_solr_url
  end
  
  def indexes
    @indexes || []
  end
  
  def map_instance_to_document_instances(instance)
    return_array = []
    indexes.each do |index|
      return_array += index.map_instance_to_document_instances(instance)
    end
    return_array.compact
  end
end

require "solr_flare/solr_flare_config"
require "solr_flare/active_record_extentions"
require "solr_flare/column"
require "solr_flare/index"
require "solr_flare/result"
require "solr_flare/encryption"