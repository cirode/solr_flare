class SolrFlare::Column
  attr_accessor :name, :definition
  
  def initialize(name, definition)
    self.name = name.to_sym
    self.definition = definition
  end
  
  def get_data(instance)
    data = [instance]
    definition.each do |mapping_method|
      data = data.collect{|di| di.respond_to?(mapping_method) ? di.send(mapping_method) : nil}.flatten.compact
    end
    data
  end
end