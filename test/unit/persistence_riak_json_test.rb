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
  it "saves via collection.insert()" do
    user = User.new
    User.collection = MiniTest::Mock.new
    User.collection.expect :insert, nil, [user]
    
    # Calling model.save() should result in a collection.insert() call
    user.save({:validate => false})
    User.collection.verify
    
    # Reset
    User.collection = nil
  end

  it "updates via collection.update()" do
    user = User.new username: 'TestUserInitial'
    User.collection = MiniTest::Mock.new
    User.collection.expect :insert, nil, [user]
    
    # model.update() is implemented as a save() call (with updated attributes)
    user.update({ username: 'TestUserNewName'} )
    User.collection.verify
    
    # Reset
    User.collection = nil
  end
  
  it "destroys via collection.remove()" do
    user = User.new
    User.collection = MiniTest::Mock.new
    User.collection.expect :remove, nil, [user]
    
    # Calling model.destroy() should result in a collection.remove() call
    user.destroy
    User.collection.verify
    
    # Reset
    User.collection = nil
  end
  
  it "returns nil when doing a find() for nil or empty key" do
    User.find(nil).must_be_nil
    User.find('').must_be_nil
  end
  
  it "performs a find() via collection.find_by_key()" do
    test_key = 'user123'
    User.collection = MiniTest::Mock.new
    User.collection.expect :find_by_key, nil, [test_key]
    
    # Calling Model class find() should result in a collection.find_by_key()
    User.find(test_key)
    User.collection.verify
    
    # Reset
    User.collection = nil
  end
end