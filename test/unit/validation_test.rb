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
  it "supports ActiveModel validations" do
    @new_user = User.new
    refute @new_user.valid?, "User requires a username to be present"
    assert @new_user.errors.messages.include?(:username), "Missing username validation error when saving"
    
    @new_user.username = "TestUser"
    assert @new_user.valid?, "User should now be valid, after setting a username"
  end
  
  it "raises InvalidDocumentError on save!()" do
    @new_user = User.new
    refute @new_user.valid?, "User requires a username to be present"
    lambda { @new_user.save! }.must_raise Riagent::InvalidDocumentError
  end
end