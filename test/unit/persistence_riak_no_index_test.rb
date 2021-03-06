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
    contact = Contact.new
    
    contact.must_respond_to :save
    contact.must_respond_to :save!
    contact.must_respond_to :update
    contact.must_respond_to :update_attributes  # alias for update()
    contact.must_respond_to :update!
    contact.must_respond_to :destroy
  end
  
  it "#model persistence class methods" do
    Contact.persistence.must_respond_to :all
    Contact.persistence.must_respond_to :find
  end
end