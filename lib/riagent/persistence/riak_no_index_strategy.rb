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
      attr_writer :client
      attr_writer :riak_object
      
      # @return [Boolean] Does this persistence strategy support querying?
      def allows_query?
        false
      end
      
      def bucket
        @bucket ||= self.client.bucket(self.collection_name)
      end
      
      def client
        @client ||= Riagent.riak_client  # See lib/configuration.rb
      end
      
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
      # @return [ActiveDocument|nil] ActiveDocument instance, or nil if the Riak Object is nil
      def from_riak_object(robject, persisted=false)
        return nil if robject.nil?
        active_doc_instance = self.model_class.from_json(robject.raw_data, robject.key)
        if persisted
          active_doc_instance.persist!  # Mark as persisted / not new
        end
        active_doc_instance
      end
      
      def insert(document)
        if document.key.present?
          # Attempt to fetch existing object, just in case
          existing_object = self.bucket.get_or_new(document.key)
          self.riak_object = existing_object if existing_object.present?
        end
        riak_obj = self.riak_object
        riak_obj.key = document.key
        riak_obj.raw_data = document.to_json_document
        riak_obj = riak_obj.store
        document.key = riak_obj.key
      end
      
      def riak_object
        @riak_object ||= Riak::RObject.new(self.bucket).tap do |obj|
          obj.content_type = "application/json"
        end
      end
    end
  end
end