# Include hook code here
require 'rsolr'
require 'nokogiri'
require 'solr_flare'
require "solr_flare/solr_flare_config"
require "solr_flare/active_record_extentions"
require "solr_flare/column"
require "solr_flare/index"
require "solr_flare/result"
require "solr_flare/encryption"
ActiveRecord::Base.send(:include, SolrFlare::ActiveRecordExtentions)

#Go through and pre-load all the model files otherwise the definitions wont show up
dirname = "#{RAILS_ROOT}/app/models/"
Dir.new(dirname).entries.each do |file_name|
  if file_name.match(/.*\.rb/)
    require "#{dirname}#{file_name}"
  end
end