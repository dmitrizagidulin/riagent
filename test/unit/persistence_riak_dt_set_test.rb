## ------------------------------------------------------------------- 
## 
## Copyright (c) "2014" Dmitri Zagidulin
##
## This file is provided to you under the Apache License,
## Version 2.0 (the "License"); you may not use this file
## except in compliance with the License.  You may obtain
## a copy of the License at
##
##   http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied.  See the License for the
## specific language governing permissions and limitations
## under the License.
##
## -------------------------------------------------------------------

require 'test_helper'

describe "a Riagent::ActiveDocument that persists via RiakDTSetStrategy" do
  it "#model persistence instance methods" do
    category = Category.new
    
    category.must_respond_to :save
    category.must_respond_to :save!
    category.must_respond_to :update
    category.must_respond_to :update_attributes  # alias for update()
    category.must_respond_to :update!
    category.must_respond_to :destroy
  end
  
  it "#model persistence class methods" do
    Category.persistence.must_respond_to :all
    Category.persistence.must_respond_to :find
  end
  
  it "keeps collection key lists in a Set type bucket" do
    Category.persistence.key_lists_bucket.must_be_kind_of Riak::Bucket
    
    Category.persistence.key_list_set.must_be_kind_of Riak::Crdt::Set
    Category.persistence.key_list_set.key.must_equal '_rg_keys_categories'
  end
  
  it "keeps a list of keys in a Crdt::Set object" do
    Category.persistence.key_list_set = MiniTest::Mock.new
    # Collection retrieves a list of all keys as a contents (members()) of a set object
    Category.persistence.key_list_set.expect :members, []
    Category.persistence.all_keys
    Category.persistence.key_list_set.verify
    
    Category.persistence.key_list_set = nil  # reset
  end
  
  it "uses a multi-get (get_many()) to fetch all documents in a collection" do
    # Mock the key list operation
    mock_key_list = ['123']
    Category.persistence.key_list_set = MiniTest::Mock.new
    Category.persistence.key_list_set.expect :members, mock_key_list  # return mock key list
    
    # Now mock and verify the 'get all documents' operation
    mock_document = Category.new
    mock_document.key = '123'
    Category.persistence.bucket = MiniTest::Mock.new
    
    # get_many() returns the document key/value hash
    Category.persistence.bucket.expect :get_many, { '123' => mock_document }, [mock_key_list]
    all_docs = Category.all
    Category.persistence.bucket.verify
    all_docs.must_equal [ mock_document ]  # all() returns just the documents
    
    # Reset
    Category.persistence.key_list_set = nil
    Category.persistence.bucket = nil
  end
end