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
  it "can be composed of other embedded ActiveDocuments" do
    address_book = AddressBook.new user_key: 'earl-123'
    c1 = Contact.new contact_name: 'Joe', contact_email: 'joe@test.net'
    c2 = Contact.new contact_name: 'Jane', contact_email: 'jane@test.net'
    address_book.contacts << c1
    address_book.contacts << c2
    json_str = address_book.to_json_document
    
    new_book = AddressBook.from_json json_str
    new_book.contacts.count.must_equal 2
    contact = new_book.contacts.first
    contact.contact_name.must_equal 'Joe'
    contact.must_be_kind_of Contact
  end
end