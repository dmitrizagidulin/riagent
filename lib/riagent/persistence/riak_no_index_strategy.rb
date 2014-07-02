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
require "riagent/persistence/persistence_strategy"

module Riagent
  module Persistence
    class RiakNoIndexStrategy < PersistenceStrategy
      attr_writer :bucket
      
      # Return all the documents in the collection.
      # Since this is a "no index" strategy, this can only be done via a streaming list keys
      # @param [Integer] results_limit Number of results returned (currently ignored)
      # @return [Array<Riagent::ActiveDocument>] List of ActiveDocument instances
      def all(results_limit)
        self.bucket.keys.inject([]) do |acc, k|
          obj = self.find(k)
          obj ? acc << obj : acc
        end
      end
      
      # @return [Boolean] Does this persistence strategy support querying?
      def allows_query?
        false
      end
      
      # @return [Riak::Bucket] Riak bucket associated with this model/collection
      def bucket
        @bucket ||= self.client.bucket(self.collection_name)
      end
      
      # @return [Riak::Client] Riak client (lazy-initialized, cached in current Thread)
      def client
        @client ||= Riagent.riak_client  # See lib/configuration.rb
      end

      # Fetch a document by key.
      # @param [String] key
      # @return [ActiveDocument|nil]
      def find(key)
        begin
          result = self.bucket.get(key)
        rescue Riak::FailedRequest => fr
          if fr.not_found?
            result = nil
          else
            raise fr
          end
        end
        self.from_riak_object(result)
      end
      
      # Converts from a Riak::RObject instance to an instance of ActiveDocument
      # @param [Riak::RObject] riak_object
      # @param [Boolean] persisted Mark the document as persisted/not new?
      # @return [ActiveDocument|nil] ActiveDocument instance, or nil if the Riak Object is nil
      def from_riak_object(riak_object, persisted=true)
        return nil if riak_object.nil?
        active_doc_instance = self.model_class.from_json(riak_object.raw_data, riak_object.key)
        if persisted
          active_doc_instance.persist!  # Mark as persisted / not new
        end
        active_doc_instance.source_object = riak_object
        active_doc_instance
      end
      
      # @param [RiakJson::ActiveDocument] document Document to be inserted
      # @return [Integer] Document key
      def insert(document)
        if document.key.present?
          # Attempt to fetch existing object, just in case
          riak_object = self.bucket.get_or_new(document.key)
        else
          riak_object = self.new_riak_object()
        end
        riak_object.raw_data = document.to_json_document
        riak_object = riak_object.store
        document.source_object = riak_object  # store the riak object in document
        document.key = riak_object.key
      end
      
      # @param [String|nil] Optional key
      # @return [Riak::RObject] New Riak object instance for this model/collection
      def new_riak_object(key=nil)
        Riak::RObject.new(self.bucket, key).tap do |obj|
          obj.content_type = "application/json"
        end
      end
      
      # Deletes the riak object that stores the document
      # @param [RiakJson::ActiveDocument] document Document to be deleted
      def remove(document)
        self.new_riak_object(document.key).delete
        document.source_object = nil
      end
      
      # @param [RiakJson::ActiveDocument] document Document to be updated
      # @return [Integer] Document key
      def update(document)
        self.insert(document)
      end
    end
  end
end