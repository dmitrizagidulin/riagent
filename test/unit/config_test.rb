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

describe "Riagent" do
  it "provides a configuration hash" do
    Riagent.config.must_be_kind_of Hash
    Riagent.config.wont_be_empty  # The config file was initialized by test_helper.rb
    Riagent.must_respond_to :load_config_file
    Riagent.must_respond_to :init_clients
    Riagent.must_respond_to :init_riak_json_client
    Riagent.must_respond_to :riak_json_client
    Riagent.must_respond_to :init_riak_client
    Riagent.must_respond_to :riak_client
  end
  
  it "initializes a RiakJson client" do
    # This should have been initialized from config file in test_helper.rb
    Riagent.riak_json_client.must_be_kind_of RiakJson::Client
  end
  
  it "initializes a Riak ruby client" do
    # This should have been initialized from config file in test_helper.rb
    Riagent.riak_client.must_be_kind_of Riak::Client
  end
end