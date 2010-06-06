# Include hook code here
SOLRFLARE_ROOT= RAILS_ROOT
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