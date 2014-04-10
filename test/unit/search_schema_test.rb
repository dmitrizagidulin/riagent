require 'test_helper'

describe "an Active Document" do
  it "can build a RiakJson schema from the annotated attributes" do
    schema = User.schema
    schema.must_be_kind_of RiakJson::CollectionSchema
    schema.fields.wont_be_empty
    schema.fields.count.must_equal 2
    schema.fields[0][:name].to_s.must_equal 'username'
    schema.fields[0][:type].must_equal 'text'
    schema.fields[0][:require].must_equal true
    schema.fields[1][:name].to_s.must_equal 'email'
    schema.fields[1][:type].must_equal 'string'
    schema.fields[1][:require].must_equal true
  end
  
  it "can save the Solr indexing schema to RiakJson" do
    schema = User.schema
    User.collection = MiniTest::Mock.new

    # Ensure that calling User.save_solr_schema() results in a call to collection.set_schema()
    User.collection.expect :set_schema, nil, [RiakJson::CollectionSchema]
    User.save_solr_schema
    User.collection.verify
  end
end