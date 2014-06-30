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

require "active_support/concern"
require "riagent/persistence/riak_json_strategy"
require "riagent/persistence/riak_no_index_strategy"
require "riagent/collection/riak_collection"

module Riagent
  # Provides a common persistence API for RiakJson Documents.
  # Most persistence calls are delegated to the Collection class instance,
  # which are implemented in persistence/*_strategy.rb modules.
  module Persistence
    extend ActiveSupport::Concern
    
    COLLECTION_TYPES = [:riak_json, :riak_no_index]
    
    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :create, :update, :save, :destroy
    end
    
    # Delete the document from its collection
    def destroy
      run_callbacks(:destroy) do
        self.class.collection.remove(self)
        @destroyed = true
      end
    end
    
    # Performs validations and saves the document
    # The validation process can be skipped by passing <tt>validate: false</tt>.
    # Also triggers :before_create / :after_create type callbacks
    # @return [String] Returns the key for the inserted document
    def save(options={:validate => true})
      context = self.new_record? ? :create : :update
      return false if options[:validate] && !valid?(context)
      
      run_callbacks(context) do
        if context == :create
          result = self.class.collection.insert(self)
        else
          result = self.class.collection.update(self)
        end
        self.persist!
        result
      end
    end
    
    # Attempts to validate and save the document just like +save+ but will raise a +Riagent::InvalidDocumentError+
    # exception instead of returning +false+ if the doc is not valid.
    def save!(options={:validate => true})
      unless save(options)
        raise Riagent::InvalidDocumentError.new(self)
      end
      true
    end
    
    # Update an object's attributes and save it
    def update(attrs)
      run_callbacks(:update) do
        self.attributes = attrs
        self.save
      end
    end
    
    # Perform an update(), raise an error if the doc is not valid
    def update!(attrs)
      unless update(attrs)
        raise Riagent::InvalidDocumentError.new(self)
      end
      true
    end
    
    # Update attributes (alias for update() for Rails versions < 4)
    def update_attributes(attrs)
      self.update(attrs)
    end
    
    module ClassMethods
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
      
      # Set the document's persistence strategy
      # Usage:
      # <code>
      # class SomeModel
      #   include Riagent::ActiveDocument
      #   collection_type :riak_json  # persist to a RiakJson::Collection
      # end
      # </code>
      def collection_type(coll_type)
        unless COLLECTION_TYPES.include? coll_type
          raise ArgumentError, "Invalid collection type: #{coll_type.to_s}"
        end
        @collection_type = coll_type
        case @collection_type
        when :riak_json
          self.persistence_strategy = :riak_json
          include Riagent::Persistence::RiakJsonStrategy
        when :riak_no_index
          self.persistence_strategy = :riak_no_index
          include Riagent::Persistence::RiakNoIndexStrategy
        end
      end
      
      # Load a document by key.
      def find(key)
        return nil if key.nil? or key.empty?
        doc = self.collection.find_by_key(key)
        self.from_rj_document(doc, persisted=true)
      end
      
      # Return the first document that matches the query
      def find_one(query)
        unless self.strategy_allows_query?
          raise NotImplementedError, "This collection type does not support querying"
        end
        if query.kind_of? Hash
          query = query.to_json
        end
        doc = self.collection.find_one(query)
        if doc.present?
          self.from_rj_document(doc, persisted=true) 
        end
      end
      
      def get_collection_type
        @collection_type ||= nil
      end
      
      def persistence_strategy
        @persistence_strategy ||= nil
      end
      
      def persistence_strategy=(strategy)
        @persistence_strategy = strategy
      end
      
      # Return all documents that match the query
      def where(query)
        unless self.strategy_allows_query?
          raise NotImplementedError, "This collection type does not support querying"
        end
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