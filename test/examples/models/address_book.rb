## ------------------------------------------------------------------- 
## 
## Copyright (c) "2014-2015" Dmitri Zagidulin and Basho Technologies, Inc.
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

require_relative 'contact'

# Sample model demonstrating embedding of other ActiveDocuments
# See test/examples/models/contact.rb (the model that's being embedded)
# See also test/unit/embedded_test.rb
class AddressBook
  include Riagent::ActiveDocument

  collection_type :riak_kv
  
  attribute :contacts, Set[Contact]
end