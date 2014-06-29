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

describe "a Riagent::ActiveDocument has Persistence options" do
  context "via collection_type :riak_json" do
    it "#model class methods" do
      # Adding the line +collection_type :riak_json+ to a model 
      # means that it will be persisted to a RiakJson::Collection
      User.get_collection_type.must_equal :riak_json
      User.persistence_strategy.must_equal :riak_json
      
      # It also grants access to a RiakJson::Client instance, to the model class
      User.client.must_be_kind_of RiakJson::Client
      
      User.collection.must_be_kind_of RiakJson::Collection
      User.collection_name.must_equal 'users'
    end
    
    it "can only persist to valid collection types" do
      lambda { User.collection_type :invalid }.must_raise ArgumentError
    end
    
    it "#:riak_no_index collection type" do
      # Adding the line +collection_type :riak_no_index+ to a model 
      # means that it will be persisted as a Riak object with no indices (k/v operations only)
      UserPreference.get_collection_type.must_equal :riak_no_index
      UserPreference.persistence_strategy.must_equal :riak_no_index
      
      # It also grants access to a RiakJson::Client instance, to the model class
      UserPreference.client.must_be_kind_of Riak::Client
      
#      User.collection.must_be_kind_of RiakJson::Collection
#      User.collection_name.must_equal 'users'
    end
  end
end