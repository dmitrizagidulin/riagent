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

module Riagent
  module Persistence
    extend ActiveSupport::Concern
    
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
      context = new_record? ? :create : :update
      return false if options[:validate] && !valid?(context)
      
      run_callbacks(context) do
        result = self.class.collection.insert(self)
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
      def client
        @client ||= nil
      end
      
      def client=(client)
        @client = client
      end
      
      # Determines the document's persistence strategy
      # Valid options: [:riak_json]
      # Usage:
      # <code>
      # class SomeModel
      #   include Riagent::ActiveDocument
      #   collection_type :riak_json  # persist to a RiakJson::Collection
      # end
      # </code>
      def collection_type(coll_type)
        @collection_type = coll_type
        case @collection_type
        when :riak_json
          self.persistence_strategy = :riak_json
          include Riagent::Persistence::RiakJsonStrategy
          self.client = self.riak_json_client()
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
    end
  end
end