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

describe "a Riagent::ActiveDocument that persists via RiakNoIndex strategy" do
  it "#model persistence instance methods" do
    user_pref = UserPreference.new
    
    # Adding the line +collection_type :riak_no_index+ to a model 
    # exposes the usual array of persistence methods
    user_pref.must_respond_to :save
    user_pref.must_respond_to :save!
    user_pref.must_respond_to :update
    user_pref.must_respond_to :update_attributes  # alias for update()
    user_pref.must_respond_to :update!
    user_pref.must_respond_to :destroy
  end
  
  it "#model persistence class methods" do
    UserPreference.must_respond_to :all
    UserPreference.must_respond_to :find
  end

#  it "saves via bucket.store()" do
#    user_pref = UserPreference.new
#    UserPreference.collection.bucket = MiniTest::Mock.new
#    UserPreference.collection.bucket.expect :store, nil, [user_pref]
#
#    # Calling model.save() should result in a collection.insert() call
#    user_pref.save({:validate => false})
#    UserPreference.collection.verify
#
#    # Reset
#    UserPreference.collection = nil
#  end
#
#  it "updates via collection.update()" do
#    user_pref = UserPreference.new email_format: 'txt'
#    user_pref.persist!  # Updates only make sense for a persisted document
#    UserPreference.collection = MiniTest::Mock.new
#    UserPreference.collection.expect :update, nil, [user_pref]
#
#    # model.update() is implemented as a save() call (with updated attributes)
#    user_pref.update({ email_format: 'html'} )
#    UserPreference.collection.verify
#
#    # Reset
#    UserPreference.collection = nil
#  end
#  
#  it "destroys via collection.remove()" do
#    user_pref = UserPreference.new
#    UserPreference.collection = MiniTest::Mock.new
#    UserPreference.collection.expect :remove, nil, [user_pref]
#
#    # Calling model.destroy() should result in a collection.remove() call
#    user_pref.destroy
#    UserPreference.collection.verify
#
#    # Reset
#    UserPreference.collection = nil
#  end
  
#  it "returns nil when doing a find() for nil or empty key" do
#    User.find(nil).must_be_nil
#    User.find('').must_be_nil
#  end
#  
#  it "performs a find() via collection.find_by_key()" do
#    test_key = 'user123'
#    User.collection = MiniTest::Mock.new
#    User.collection.expect :find_by_key, nil, [test_key]
#    
#    # Calling Model class find() should result in a collection.find_by_key()
#    User.find(test_key)
#    User.collection.verify
#    
#    # Reset
#    User.collection = nil
#  end
#  
#  it "performs a all() via collection.all()" do
#    User.collection = MiniTest::Mock.new
#    User.collection.expect :all, [], [1000]  # default results limit of 1000
#    
#    # Calling Model class where() should result in a collection.all()
#    User.all()
#    User.collection.verify
#    
#    # Reset
#    User.collection = nil
#  end
#  
#  it "performs a where() via collection.find_all()" do
#    User.collection = MiniTest::Mock.new
#    query = { country: 'USA' }
#    User.collection.expect :find_all, [], [query.to_json]
#    
#    # Calling Model class where() should result in a collection.find_all()
#    User.where(query)
#    User.collection.verify
#    
#    # Reset
#    User.collection = nil
#  end
#  
#  it "performs a find_one() via collection.find_one()" do
#    User.collection = MiniTest::Mock.new
#    query = { username: 'TestUser' }
#    User.collection.expect :find_one, [], [query.to_json]
#    
#    # Calling Model class find_one() should result in a collection.find_one()
#    User.find_one(query)
#    User.collection.verify
#    
#    # Reset
#    User.collection = nil
#  end
end