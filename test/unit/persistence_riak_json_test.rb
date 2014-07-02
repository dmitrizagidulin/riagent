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

describe "a Riagent::ActiveDocument that persists to RiakJson" do
  it "#model persistence instance methods" do
    user = User.new
    
    # Adding the line +collection_type :riak_json+ to a model 
    # exposes the usual array of persistence methods
    user.must_respond_to :save
    user.must_respond_to :save!
    user.must_respond_to :update
    user.must_respond_to :update_attributes  # alias for update()
    user.must_respond_to :update!
    user.must_respond_to :destroy
  end
  
  it "#model persistence class methods" do
    User.must_respond_to :all
    User.must_respond_to :find
    User.must_respond_to :find_one
    User.must_respond_to :where
  end
  
  it "saves via collection.insert()" do
    user = User.new
    User.persistence.collection = MiniTest::Mock.new
    User.persistence.collection.expect :insert, nil, [user]
    
    # Calling model.save() should result in a collection.insert() call
    user.save({:validate => false})
    User.persistence.collection.verify
    
    # Reset
    User.persistence.collection = nil
  end

  it "updates via collection.update()" do
    user = User.new username: 'TestUserInitial'
    user.persist!  # Updates only make sense for a persisted document
    User.persistence.collection = MiniTest::Mock.new
    User.persistence.collection.expect :update, nil, [user]
    
    # model.update() is implemented as a save() call (with updated attributes)
    user.update({ username: 'TestUserNewName'} )
    User.persistence.collection.verify
    
    # Reset
    User.persistence.collection = nil
  end
  
  it "destroys via collection.remove()" do
    user = User.new
    user.key = 'user123'
    user.persist!  # Remove can only be called on persisted objects that have a key
    User.persistence.collection = MiniTest::Mock.new
    User.persistence.collection.expect :remove, nil, [user]
    
    # Calling model.destroy() should result in a collection.remove() call
    user.destroy
    User.persistence.collection.verify
    
    # Reset
    User.persistence.collection = nil
  end
  
  it "returns nil when doing a find() for nil or empty key" do
    User.find(nil).must_be_nil
    User.find('').must_be_nil
  end
  
  it "performs a find() via collection.find_by_key()" do
    test_key = 'user123'
    User.persistence.collection = MiniTest::Mock.new
    User.persistence.collection.expect :find_by_key, nil, [test_key]
    
    # Calling Model class find() should result in a collection.find_by_key()
    User.find(test_key)
    User.persistence.collection.verify
    
    # Reset
    User.persistence.collection = nil
  end
  
  it "performs an all() listing via collection.all()" do
    User.persistence.collection = MiniTest::Mock.new
    User.persistence.collection.expect :all, [], [1000]  # default results limit of 1000
    
    # Calling Model class where() should result in a collection.all()
    User.all()
    User.persistence.collection.verify
    
    # Reset
    User.persistence.collection = nil
  end
  
  it "performs a where() via collection.find_all()" do
    User.persistence.collection = MiniTest::Mock.new
    query = { country: 'USA' }
    User.persistence.collection.expect :find_all, [], [query.to_json]
    
    # Calling Model class where() should result in a collection.find_all()
    User.where(query)
    User.persistence.collection.verify
    
    # Reset
    User.persistence.collection = nil
  end
  
  it "performs a find_one() via collection.find_one()" do
    User.persistence.collection = MiniTest::Mock.new
    query = { username: 'TestUser' }
    User.persistence.collection.expect :find_one, [], [query.to_json]
    
    # Calling Model class find_one() should result in a collection.find_one()
    User.find_one(query)
    User.persistence.collection.verify
    
    # Reset
    User.persistence.collection = nil
  end
end