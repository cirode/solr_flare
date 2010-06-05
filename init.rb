# Include hook code here
SOLRFLARE_ROOT= RAILS_ROOT
require 'rsolr'
require 'nokogiri'
ActiveRecord::Base.send(:include, SolrFlare::ActiveRecordExtentions)