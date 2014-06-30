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

require "riak"
require "active_support/concern"

module Riagent
  module Persistence
    module RiakNoIndexStrategy
      extend ActiveSupport::Concern
      module ClassMethods
        # @return [Riak::Client|nil] Riak client instance
        def client
          @client ||= Riagent.riak_client  # See lib/configuration.rb
        end
        
        # @param [Riak::Client] client
        def client=(client)
          @client = client
        end
        
        # Returns a Riagent::RiakCollection instance for this document
        # (thin wrapper for a regular Riak bucket, see lib/collection/riak_collection.rb)
        def collection
          @collection ||= Riagent::RiakCollection.new(self.collection_name, self.client)
        end
        
        # Sets the Riagent::RiakCollection instance for this document
        # (thin wrapper for a regular Riak bucket, see lib/collection/riak_collection.rb)
        def collection=(collection_obj)
          @collection = collection_obj
        end
        
        # @return [Boolean] Does this persistence strategy support querying?
        def strategy_allows_query?
          false
        end
      end
    end
  end
end