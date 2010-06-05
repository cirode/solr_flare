require 'yaml'
require 'erb'
class SolrFlare::SolrFlareConfig
  def self.read_config(config_file)
    YAML.load(ERB.new(IO.read(config_file)).result)
  end
end