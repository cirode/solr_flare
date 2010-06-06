##
# Holds the defination of each column in an index.
#
class SolrFlare::Column
  attr_accessor :name, :definition
  
  def initialize(name, definition)
    self.name = name.to_sym
    self.definition = definition
  end
  
  ##
  # Runs through the mappings to map an instance to the actual datum or data
  #
  def get_data(instance)
    data = []
    unless definition.empty?
      data << instance
      definition.each do |mapping_method|
        data = data.collect{|di| di.respond_to?(mapping_method) ? di.send(mapping_method) : nil}.flatten.compact
      end
    end
    data
  end
end