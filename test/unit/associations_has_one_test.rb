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

describe "Riagent::Document Associations" do
  context "has_one association" do
    it "adds a <target>_key attribute" do
      # a User model includes a 'has_one :address_book' association
      User.attribute_set[:address_book_key].wont_be_nil
      user = User.new
      user.must_respond_to :address_book_key
    end
    
    it "adds getter and setter methods for the target" do
      user = User.new
      user.must_respond_to :address_book
      user.must_respond_to :address_book=
    end
    
    it "assigning a target object sets corresponding <target>_key and <target> attribute values" do
      user = User.new
      address_book = AddressBook.new
      address_book.key = 'test-book-123'
      
      user.address_book = address_book
      
      user.address_book_key.must_equal 'test-book-123'
      
      user.address_book.must_be_kind_of AddressBook
    end
    
    it "adds a build_<target> method" do
      
    end
  end
end