## ------------------------------------------------------------------- 
## 
## Copyright (c) "2014" Dmitri Zagidulin and Basho Technologies, Inc.
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

TEST_USERNAME = 'earl'
TEST_USERNAME_2 = 'count'

def test_user(test_key='earl-123')
  user = User.new username: TEST_USERNAME, email: 'earl@desandwich.com'
  user.key = test_key
  user
end

describe "a Riagent::ActiveDocument's Persistence Layer" do  
  it "can save a document and generate a key" do
    user = User.new username: TEST_USERNAME
    generated_key = user.save
    
    generated_key.wont_be_nil "Key not generated from document.save"
    generated_key.wont_be_empty "Key not generated from document.save"
    generated_key.must_be_kind_of String
    user.key.must_equal generated_key
    
    refute user.new_record?, "Document should not be marked as new after saving"
    assert user.persisted?, "Document should be marked as persisted after saving"
    
    # Clean up
    user.destroy
  end
  
  it "can read, update and delete a document" do
    test_key = 'george-123'
    new_user = User.new username: 'george', email: 'george@washington.com'
    new_user.key = test_key
    new_user.save
    
    found_user = User.find(test_key) # Load User by key
    found_user.must_be_kind_of User
    found_user.key.must_equal test_key
    refute found_user.new_record?, "A loaded by key user object is not new"
    assert found_user.persisted?, "A loaded by key user object should be markes as persisted"
    
    new_attributes = {username: 'henry', email: 'henry@gmail.com' }
    found_user.update(new_attributes)  # Also saves
    
    updated_user = User.find(test_key)
    updated_user.username.must_equal 'henry'
    
    found_user.destroy
    assert found_user.destroyed?
  end
  
  it "returns an empty array for queries that return no results" do
    query = { username: 'nonexistent' }
    result = User.where(query)
    result.must_be_empty
  end
end