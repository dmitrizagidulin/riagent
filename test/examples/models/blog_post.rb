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

class BlogPost
  include Riagent::ActiveDocument
  
  collection_type :riak_kv
  
  # Explicit attributes
  # key is an implied attribute, present in all ActiveDocument instances
  attribute :title, String
  attribute :description, String
  attribute :body, String
end