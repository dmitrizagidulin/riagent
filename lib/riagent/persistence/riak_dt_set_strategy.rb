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
      
      # Adds a key to the collection key list (usually done as part of an insert)
      # Added as a standalone method for ease of testing
      # @param [String] key Key to be added to list
      def add_key(key)
        self.key_list_set.add(key)
      end
      
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
      
      # Return all keys in the collection
      # @return [Array<String>] List of all keys in the collection
      def all_keys
        self.key_list_set.members.to_a
      end
      
      # Deletes a key from the key list (usually called by remove()).
      def delete_key(key)
        key_list_set = self.key_list_set.reload
        key_list_set.remove(key)
      end
      
      # Clears the key list set
      def delete_key_list
        # Perform a Riak DELETE operation (using the bucket type interface)
        self.key_lists_bucket.delete self.key_list_set_name, type: 'sets'
      end
      
      # Insert a document into the collection.
      # Also inserts the document's key into the key list set.
      # @param [Riagent::ActiveDocument] document Document to be inserted
      # @return [String] Document key
      def insert(document)
        doc_key = super
        self.add_key(doc_key)
        doc_key
      end
      
      # Return the Crdt Set object that keeps track of keys in this collection
      # @return [Riak::Crdt::Set]
      def key_list_set 
        # Note: Assumes that the Bucket Type for Sets is the default 'sets'
        @key_list_set || Riak::Crdt::Set.new(self.key_lists_bucket, self.key_list_set_name)
      end
      
      # Return the key name of the set that keeps track of keys in this collection
      # @return [String]
      def key_list_set_name
        '_rg_keys_' + self.collection_name()
      end
      
      # Return the bucket in which the Riagent collection key lists are kept
      # @return [Riak::Bucket]
      def key_lists_bucket
        self.client.bucket('_rg_key_lists')
      end
      
      # Delete a document from a collection, and delete its key from the key list set
      # @param [Riagent::ActiveDocument] document Document to be removed
      def remove(document)
        doc_key = document.key
        super
        self.delete_key(doc_key)
      end
    end
  end
end