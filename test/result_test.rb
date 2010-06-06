require 'test_helper'
require "#{File.dirname(__FILE__)}/testing_stubs/fake_document.rb"
require "#{File.dirname(__FILE__)}/testing_stubs/fake_document_type_2.rb"

class ResultTest < ActiveSupport::TestCase
  test "given a correct empty result it gets parsed correctly" do
    return_data = '<?xml version="1.0" encoding="UTF-8"?>
    <response>
    <lst name="responseHeader">
     <int name="status">0</int>
     <int name="QTime">19</int>
    </lst>
    <result name="response" numFound="0" start="0" maxScore="0">
    </result>
    </response>'
    result = SolrFlare::Result.new(return_data, 10)
    assert_instance_of( SolrFlare::Result,result)
    assert_equal(result.size, 0)
  end
  
  test "given a correct non empty result it gets parsed correctly and correct model gets grabbed from database" do
    return_data = '<?xml version="1.0" encoding="UTF-8"?>
    <response>
    <lst name="responseHeader">
     <int name="status">0</int>
     <int name="QTime">19</int>
    </lst>
    <result name="response" numFound="1" start="0" maxScore="0.614891">
     <doc>
      <float name="score">0.614891</float>
      <str name="id">2_FakeDocument</str>
      <int name="instance_id">2</int>
      <str name="model_name">FakeDocument</str>
     </doc>
    </result>
    </response>'
    result = SolrFlare::Result.new(return_data, 10)
    assert_instance_of( SolrFlare::Result, result)
    assert_equal(result.size, 1)
    assert_instance_of( FakeDocument,result[0])
    assert_equal(result[0].id, 2)
  end
  
  test "given a non empty result that doesnt exist and one that does it silently gets only those it can" do
    return_data = '<?xml version="1.0" encoding="UTF-8"?>
    <response>
    <lst name="responseHeader">
     <int name="status">0</int>
     <int name="QTime">19</int>
    </lst>
    <result name="response" numFound="2" start="0" maxScore="0.614891">
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocument</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocument</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">2_FakeDocumentType2</str>
      <int name="instance_id">2</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
    </result>
    </response>'
    result = SolrFlare::Result.new(return_data, 10)
    assert_instance_of( SolrFlare::Result, result)
    assert_equal(result.size, 1)
    assert_instance_of( FakeDocumentType2,result[0])
    assert_equal(result[0].id, 2)
  end
  
  test "given a non empty result whose model doesnt exist and one that does it silently gets only those it can" do
    return_data = '<?xml version="1.0" encoding="UTF-8"?>
    <response>
    <lst name="responseHeader">
     <int name="status">0</int>
     <int name="QTime">19</int>
    </lst>
    <result name="response" numFound="2" start="0" maxScore="0.614891">
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType3</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType3</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">2_FakeDocumentType2</str>
      <int name="instance_id">2</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
    </result>
    </response>'
    result = SolrFlare::Result.new(return_data, 10)
    assert_instance_of( SolrFlare::Result, result)
    assert_equal(result.size, 1)
    assert_instance_of(FakeDocumentType2,result[0])
    assert_equal(result[0].id, 2)
  end
  
  test "total pages should be numfound/per_page when divisable exactly" do
    return_data = '<?xml version="1.0" encoding="UTF-8"?>
    <response>
    <lst name="responseHeader">
     <int name="status">0</int>
     <int name="QTime">19</int>
    </lst>
    <result name="response" numFound="30" start="21" maxScore="0.614891">
     <doc>
      <float name="score">0.614891</float>
      <str name="id">2_FakeDocument</str>
      <int name="instance_id">2</int>
      <str name="model_name">FakeDocument</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">2_FakeDocumentType2</str>
      <int name="instance_id">2</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
    </result>
    </response>'
    result = SolrFlare::Result.new(return_data, 10)
    assert_instance_of(SolrFlare::Result, result)
    assert_equal(result.total_pages, 3)
  end
  
  test "total pages should be numfound/2+1 when not divisable exactly" do
    return_data = '<?xml version="1.0" encoding="UTF-8"?>
    <response>
    <lst name="responseHeader">
     <int name="status">0</int>
     <int name="QTime">19</int>
    </lst>
    <result name="response" numFound="32" start="30" maxScore="0.614891">
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocument</str>
      <int name="instance_id">2</int>
      <str name="model_name">FakeDocument</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
    </result>
    </response>'
    result = SolrFlare::Result.new(return_data, 10)
    assert_instance_of(SolrFlare::Result, result)
    assert_equal(result.total_pages, 4)
  end
  
  test "current_page should be (start/per_page)+1 to start at 1" do
    return_data = '<?xml version="1.0" encoding="UTF-8"?>
    <response>
    <lst name="responseHeader">
     <int name="status">0</int>
     <int name="QTime">19</int>
    </lst>
    <result name="response" numFound="32" start="30" maxScore="0.614891">
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocument</str>
      <int name="instance_id">2</int>
      <str name="model_name">FakeDocument</str>
     </doc>
     <doc>
      <float name="score">0.614891</float>
      <str name="id">1_FakeDocumentType2</str>
      <int name="instance_id">1</int>
      <str name="model_name">FakeDocumentType2</str>
     </doc>
    </result>
    </response>'
    result = SolrFlare::Result.new(return_data, 10)
    assert_instance_of(SolrFlare::Result, result)
    assert_equal(result.current_page, 4)
  end
end