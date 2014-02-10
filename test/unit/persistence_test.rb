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
  it "can persist to a RiakJson::Collection" do
    # Adding the line +collection_type :riak_json+ to a model 
    # means that it will be persisted to a RiakJson::Collection
    User.get_collection_type.must_equal :riak_json
    User.persistence_strategy.must_be_kind_of Riagent::Persistence::RiakJsonStrategy
    
    # It also grants access to a RiakJson::Client instance, to the model class
    User.client.must_be_kind_of RiakJson::Client
  end
end