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
      attr_writer :riak_object
      
      # @return [Boolean] Does this persistence strategy support querying?
      def allows_query?
        false
      end
      
      # @return [Riak::Bucket]
      def bucket
        @bucket ||= self.client.bucket(self.collection_name)
      end
      
      # @return [Riak::Client]
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
          self.riak_object = self.bucket.get_or_new(document.key)
        end
        riak_object = self.riak_object
        riak_object.key = document.key
        riak_object.raw_data = document.to_json_document
        riak_object = riak_object.store
        document.source_object = riak_object  # store the riak object in document
        document.key = riak_object.key
      end
      
      # @return [Riak::RObject]
      def riak_object
        @riak_object ||= Riak::RObject.new(self.bucket).tap do |obj|
          obj.content_type = "application/json"
        end
      end
    end
  end
end