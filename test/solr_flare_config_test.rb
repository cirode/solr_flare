require 'test_helper'
require 'tmpdir'
require 'yaml'
class SolrFlareConfigTest < ActiveSupport::TestCase
  def setup
    @default_solr_url = 'http://0.0.0.0:8983/solr'
  end
  
  # Replace this with your real tests.
  test "passing in a config base that doesnt exist should return a config with the defaults only" do
    config = SolrFlare::SolrFlareConfig.new("/tmp/this_doesnt_exist#{SolrFlare::Encryption.create_token}")
    assert_equal(config.solr_url,@default_solr_url)
  end
  
  test "asking for a config item that doesnt exist should raise an error" do
    config = SolrFlare::SolrFlareConfig.new("/tmp/this_doesnt_exist#{SolrFlare::Encryption.create_token}")
    assert_raise(NoMethodError){config.this_config_item_doesnt_exist}
  end
  
  test "full solr url without a core is the same as solr url" do
    config = SolrFlare::SolrFlareConfig.new("/tmp/this_doesnt_exist#{SolrFlare::Encryption.create_token}")
    assert_equal(config.solr_url,config.full_solr_url)
  end
  
  test "passing in a config base that does exist but no files should give the defaults only" do
    Dir.tmpdir do |dir|
      config = SolrFlare::SolrFlareConfig.new(dir)
      assert_equal(config.solr_url,@default_solr_url)
      assert_raise(NoMethodError){config.this_config_item_doesnt_exist}
    end
  end
  
  test "passing in a config base that does exist and solrflare file should give contents of flare file" do
    Dir.tmpdir do |dir|
      file_name = 'solr_flare.yml'
      core_value = 'development'
      file = Tmpfile.new(file_name,dir)
      file.write(YAML.dump(:core => core_value))
      file.flush
      config = SolrFlare::SolrFlareConfig.new(dir)
      file.close
      assert_equal(config.solr_url,@default_solr_url)
      assert_equal(config.core,core_value)
    end
  end
  
  test "environment file should override the solrflare file" do
    Dir.tmpdir do |dir|
      file_name1 = 'solr_flare.yml'
      core_value1 = 'development'
      file1 = Tmpfile.new(file_name1,dir)
      file1.write(YAML.dump(:core => core_value1))
      file1.flush
      file_name2 = "#{RAILS_ENV}.yml"
      core_value2 = 'test'
      file2 = Tmpfile.new(file_name1,dir)
      file2.write(YAML.dump(:core => core_value2))
      file2.flush
      config = SolrFlare::SolrFlareConfig.new(dir)
      file1.close
      file2.close
      assert_equal(config.solr_url, @default_solr_url)
      assert_equal(config.core,core_value2)
    end
  end
  
  test "full solr url with a core is the same as solr url" do
    Dir.tmpdir do |dir|
      file_name = 'solr_flare.yml'
      core_value = 'development'
      file = Tmpfile.new(file_name,dir)
      file.write(YAML.dump(:core => core_value))
      file.flush
      config = SolrFlare::SolrFlareConfig.new(dir)
      file.close
      assert_equal(config.solr_full_url, @default_solr_url)
      assert_equal(config.core,core_value)
    end
  end
end
