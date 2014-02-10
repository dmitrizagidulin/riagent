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

describe "a Riagent::ActiveDocument" do
  # an instance of Riagent::ActiveDocument
  # see test/models/user.rb
  let(:user_model) { User.new }
  
  it "extends Riagent::Document" do
    user_model.must_be_kind_of Riagent::Document
  end
  
  it "should know its collection name" do
    # a document's collection name is used in ActiveModel::Conversion compatibility
    User.collection_name.must_equal 'users'
  end
  
  it "uses its collection name to help form URLs" do
    user_model.key = 'test-user-123'
    user_model.to_partial_path.must_equal 'users/test-user-123'
  end
end