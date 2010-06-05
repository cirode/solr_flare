# Include hook code here
SOLRFLARE_ROOT= RAILS_ROOT
require 'rsolr'
require 'nokogiri'
require 'solr_flare'
ActiveRecord::Base.send(:include, SolrFlare::ActiveRecordExtentions)