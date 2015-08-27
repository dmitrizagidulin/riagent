## ------------------------------------------------------------------- 
## 
## Copyright (c) "2014-2015" Dmitri Zagidulin
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

module Riagent
  module Persistence
    # Riagent document persistence strategy
    class PersistenceStrategy
      attr_accessor :client
      attr_accessor :collection_name
      attr_accessor :model_class
      
      def initialize(model_class)
        self.model_class = model_class
        self.collection_name = model_class.collection_name
      end
    end
  end
end
