class SolrFlare::Index
  attr_accessor :columns,:defined_on, :dependencies, :where_block
  
  def initialize(defined_on)
    self.defined_on = defined_on
    self.dependencies = {}
    self.where_block = proc{|instance| true}
  end
  
  def column(name, options)
    definition = options[:field_chain]
    unless definition
      raise ArgumentError, "field_chain needs to be provided"
    end
    @columns  = (columns || []) + [SolrFlare::Column.new(name, definition)]
  end
  
  def dependency(class_name, options)
    reverse_chain = options[:reverse_chain]
    unless reverse_chain
      raise ArgumentError, "reverse_chain needs to be provided"
    end
    self.dependencies[class_name.to_sym] = reverse_chain
  end
  
  def where(&block)
    self.where_block = block
  end
  
  def map_instance_to_document_instances(instance)
    #NOTE: Cannot simply use the class name as this does not take into account inheritance
    document_instances = []
    unless (mapping_methods = get_mapping_methods(instance)).empty?
      document_instances << instance
      mapping_methods.each do |mapping_method|
        document_instances = document_instances.collect{|di| di.respond_to?(mapping_method) ? di.send(mapping_method) : nil}.flatten.compact
      end
    end
    if instance.is_a?(defined_on)
      document_instances << instance
    end
    document_instances
  end
  
  def build_document(instance)
    document = nil
    if is_primary_document_instance(instance) && where_block.call(instance)
      document = {:instance_id => instance.id, :model_name => defined_on.to_s}
      columns.each do |column|
        document[column.name] = column.get_data(instance)
      end
    end
    document
  end
  
  def is_primary_document_instance(instance)
    instance.is_a?(defined_on)
  end
  
  #DANGER! What about inheritance?
  def is_dependency(class_name)
    !!(defined_on.to_s.to_sym == class_name.to_sym || dependencies.keys.include?(class_name))
  end
  
  protected
  
  def get_mapping_methods(instance)
    #first map all the defined_on keys to classes
    #NOTE: Must be done after all the models have been loaded
    #then check if the classes exist
    dependencies.each do |class_string, reverse_chain|
      if (class_instance = SolrFlare.get_model_instance(class_string)) && instance.is_a?(class_instance)
        return reverse_chain
      end
    end
    return []
  end
end