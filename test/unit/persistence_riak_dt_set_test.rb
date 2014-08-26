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

describe "a Riagent::ActiveDocument that persists via RiakDTSetStrategy" do
  it "#model persistence instance methods" do
    category = Category.new
    
    category.must_respond_to :save
    category.must_respond_to :save!
    category.must_respond_to :update
    category.must_respond_to :update_attributes  # alias for update()
    category.must_respond_to :update!
    category.must_respond_to :destroy
  end
  
  it "#model persistence class methods" do
    Category.persistence.must_respond_to :all
    Category.persistence.must_respond_to :find
  end
end