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
require "active_support/concern"

module Riagent
  module Persistence
    module RiakJsonStrategy
      extend ActiveSupport::Concern
      
      module ClassMethods
        def client
          @client ||= Riagent.riak_json_client
        end
        
        def client=(client)
          @client = client
        end
        
        # Returns a RiakJson::Collection instance for this document
        def collection
          @collection ||= self.client.collection(self.collection_name)
        end
        
        # Sets the RiakJson::Collection instance for this document
        def collection=(collection_obj)
          @collection = collection_obj
        end
        
        # Converts from a RiakJson::Document instance to an instance of ActiveDocument
        # @return [ActiveDocument, nil] ActiveDocument instance, or nil if the Document is nil
        def from_rj_document(doc, persisted=false)
          return nil if doc.nil?
          active_doc_instance = self.instantiate(doc.body)
          active_doc_instance.key = doc.key
          if persisted
            active_doc_instance.persist!  # Mark as persisted / not new
          end
          active_doc_instance
        end
      end
    end
  end
end