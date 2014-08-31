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

describe "RiakDTSetStrategy persistence" do  
  it "can add keys to its collection key list" do
    assert Category.all.empty?
    Category.persistence.add_key('new_key123')
    Category.persistence.all_keys.must_equal ['new_key123']
    Category.persistence.delete_key_list
  end
  
  it "adding a document adds the key to the key list" do
    assert Category.all.empty?
    new_category = Category.new name: 'Test Category'
    new_category.key = 'category123'
    new_category.save
    
    collection_keys = Category.persistence.all_keys
    collection_keys.must_include 'category123'
    
    new_category.destroy
    collection_keys = Category.persistence.all_keys
    collection_keys.must_be_empty
  end
end