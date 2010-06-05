require 'yaml'
require 'erb'
class SolrFlare::SolrFlareConfig
  attr_accessor :config
  def initialize(config_path)
    self.config={:solr_url => 'http://0.0.0.0:8983/solr'}
    ['solrflare.yml', "#{RAILS_ENV}.yml"].each do |file|
      config_file_path = "#{config_path}/#{file}"
      begin
        self.config.merge!(YAML.load(ERB.new(IO.read(config_file_path)).result)) if File.exists?(config_file_path)
      rescue TypeError => e
        Rails.logger.warn "WARNING:: Config File #{config_file_path} is not valid ERB or YAML"
      end
    end
    self.config
  end
  
  def full_solr_url
    if core = self.config[:core]
      "#{solr_url}/#{core}"
    else
      solr_url
    end
  end
  
  def method_missing(method_name)
    if configuration = self.config[method_name.to_sym]
      return configuration
    end
    raise NoMethodError, "Configuration does not contain the item #{method_name}"
  end
end