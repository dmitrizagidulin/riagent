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

require "riak_json"
require "riagent/persistence/persistence_strategy"

module Riagent
  module Persistence
    class RiakJsonStrategy < PersistenceStrategy
      attr_writer :collection
      
      # Return all the documents in the collection
      # @param [Integer] results_limit Number of results returned
      # @return [Array|nil] of ActiveDocument instances
      def all(results_limit=1000)
        result = self.collection.all(results_limit)
        if result.present?
          result.documents.map do |doc| 
            self.from_rj_document(doc, persisted=true)
          end
        end
      end
      
      # @return [Boolean] Does this persistence strategy support querying?
      def allows_query?
        true
      end
      
      # @return [RiakJson::Client] RiakJson client for this persistence strategy (lazy initialize)
      def client
        @client ||= Riagent.riak_json_client  # See lib/configuration.rb
      end

      # @return [RiakJson::Collection] instance for this persistence strategy (lazy initialize)
      def collection
        @collection ||= self.client.collection(self.collection_name)
      end

      # Fetch a document by key.
      # @param [String] key
      # @return [ActiveDocument|nil]
      def find(key)
        return nil if key.nil? or key.empty?
        doc = self.collection.find_by_key(key)
        self.from_rj_document(doc, persisted=true)
      end
      
      # Return the first document that matches the query
      # @param [String] query RiakJson query, in JSON string form
      def find_one(query)
        if query.kind_of? Hash
          query = query.to_json
        end
        doc = self.collection.find_one(query)
        if doc.present?
          self.from_rj_document(doc, persisted=true) 
        end
      end
      
      # Converts from a RiakJson::Document instance to an instance of ActiveDocument
      # @return [ActiveDocument|nil] ActiveDocument instance, or nil if the Document is nil
      def from_rj_document(doc, persisted=false)
        return nil if doc.nil?
        active_doc_instance = self.model_class.instantiate(doc.attributes)
        active_doc_instance.key = doc.key
        if persisted
          active_doc_instance.persist!  # Mark as persisted / not new
        end
        active_doc_instance
      end
      
      # @param [RiakJson::ActiveDocument] doc Document to be inserted
      # @return [Integer] Document key
      def insert(doc)
        self.collection.insert(doc)
      end

      # @param [RiakJson::ActiveDocument] doc Document to be deleted
      def remove(doc)
        self.collection.remove(doc)
      end

      # @param [RiakJson::ActiveDocument] doc Document to be updated
      # @return [Integer] Document key
      def update(doc)
        self.collection.update(doc)
      end
      
      # Return all documents that match the query
      # @param [String] query RiakJson query, in JSON string form
      def where(query)
        if query.kind_of? Hash
          query = query.to_json
        end
        result = self.collection.find_all(query)
        if result.present?
          result.documents.map do |doc| 
            self.from_rj_document(doc, persisted=true)
          end
        end
      end
    end
  end
end