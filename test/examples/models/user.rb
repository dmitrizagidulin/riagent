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

require_relative 'address_book'
require_relative 'blog_post'

class User
  include Riagent::ActiveDocument
  
  collection_type :riak_json  # Persist to a RiakJson::Collection
  
  # Explicit attributes
  # key is an implied attribute, present in all ActiveDocument instances
  attribute :username, String, search_index: { as: :text }
  attribute :email, String, search_index: { as: :string }, default: ''
  attribute :language, String, default: 'en'
  
  # Associations
  has_one :address_book, :class => AddressBook
  has_many :posts, :class => BlogPost, :using => :solr
  
  # Validations
  validates_presence_of :username
end