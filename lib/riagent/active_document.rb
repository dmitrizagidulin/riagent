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

require 'active_support/concern'
require "active_model"
require "active_model/naming"
require 'riagent/document'
require 'riagent/conversion'
require 'riagent/persistence'
require 'riagent/search_schema'

module Riagent
  module ActiveDocument
    extend ActiveSupport::Concern
    extend ActiveModel::Naming
    include ActiveModel::Validations
    
    included do
      include Riagent::Document
      include Riagent::Conversion
      include Riagent::Persistence
      extend Riagent::SearchSchema
    end
    
    module ClassMethods
      # Returns string representation for the collection name
      # Used to determine the RiakJson::Collection name, or the Riak Bucket name
      # Uses ActiveModel::Naming functionality to derive the name
      def collection_name
        self.model_name.plural
      end
    end
  end
end