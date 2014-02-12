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

describe "Riagent::Document has_one association" do
  # If User has_one :address_book,
  # Then user is source, and address_book is target
  
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

  it "lazy loads the target object, if key is present" do
    user = User.new
    user.address_book_key = 'test-book-123'  # Set the target key manually
    user.address_book_cache.must_be_nil "Setting the target key should not load the target object instance"
    
    # Create a mock object that'll be loaded from db
    mock_loaded_address_book = AddressBook.new
    mock_loaded_address_book.key = 'test-book-123'
    
    AddressBook.collection = MiniTest::Mock.new
    AddressBook.collection.expect :find_by_key, mock_loaded_address_book, ['test-book-123']
      
    # Calling user.address_book should lazy-load via the target collection.find_by_key()
    user.address_book
    AddressBook.collection.verify
    
    # Reset
    AddressBook.collection = nil
  end
  
  it "adds a build_<target> method" do
    user = User.new
    user.key = 'test-user-123'
    
    user.build_address_book(attributes={})
    # Target object gets source object's key by default, via build_<target>()
    user.address_book.key.must_equal 'test-user-123'
  end
end