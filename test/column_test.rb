require 'test_helper'
require "#{File.dirname(__FILE__)}/testing_stubs/fake_record"

class ColumnTest < ActiveSupport::TestCase
  test "empty definition returns empty data" do
    fr = FakeRecord.new
    column = SolrFlare::Column.new('column',[])
    return_value = column.get_data(fr)
    assert_instance_of(Array,return_value)
    assert(return_value.empty?)
  end
  
  test "non empty definition allows for a tracing" do
    fr = FakeRecord.new
    column = SolrFlare::Column.new('column',[:index, :data])
    return_value = column.get_data(fr)
    assert_instance_of(Array,return_value)
    assert_equal(return_value.size ,1 )
    assert_equal(return_value[0], fr.data )
  end
  
  test "non empty definition allows for a tracing and on to many joins get multiple answers" do
    fr = FakeRecord.new
    column = SolrFlare::Column.new('column',[:index2, :data])
    return_value = column.get_data(fr)
    assert_instance_of(Array,return_value)
    assert_equal(return_value.size,2 )
    assert_equal(return_value[0], fr.data )
    assert_equal(return_value[1], fr.data )
  end
end
