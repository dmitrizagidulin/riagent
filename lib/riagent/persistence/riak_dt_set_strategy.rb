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

require "riak"
require "riagent/persistence/riak_kv_strategy"

module Riagent
  module Persistence
    class RiakDTSetStrategy < RiakKVStrategy
      attr_writer :key_list_set
      
      # Return all the documents in the collection.
      # Uses Riak 2.0 CRDT Set Data type to keep track of collection key list
      # @param [Integer] results_limit Number of results returned (currently ignored)
      # @return [Array<Riagent::ActiveDocument>] List of ActiveDocument instances
      def all(results_limit)
        keys = self.all_keys
        # TODO: Trim keys to results_limit
        all_docs_hash = self.bucket.get_many(keys)
        all_docs_hash.values
      end
      
      def all_keys
        self.key_list_set.members
      end
      
      def key_list_set 
        @key_list_set || Riak::Crdt::Set.new(self.key_lists_bucket, self.key_list_set_name)
      end
      
      def key_list_set_name
        '_rg_keys_' + self.collection_name()
      end
      
      # Return the bucket in which the Riagent collection key lists are kept
      # @return [Riak::Bucket]
      def key_lists_bucket
        self.client.bucket('_rg_key_lists')
      end
    end
  end
end