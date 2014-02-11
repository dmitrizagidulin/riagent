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

module Riagent
  # Generates RiakJson::CollectionSchema objects (translated into Solr schemas by RiakJson)
  # from annotated document attributes.
  # Usage:
  # <code>
  #   class SampleModel
  #     include Riagent::ActiveDocument
  #     collection_type :riak_json
  #     attribute :name, required: true, search_index: { as: :text }
  #   end
  #   puts SampleModel.schema.inspect
  #   # => <RiakJson::CollectionSchema:0x000001050eef10 @fields=[{:name=>"name", :type=>"text", :require=>true}]>
  #   SampleModel.collection.set_schema(SampleModel.schema)  # sets that schema for the collection
  # </code>
  module SearchSchema
    # Returns a CollectionSchema instance, derived from the document attributes
    def schema
      schema = RiakJson::CollectionSchema.new
      self.attribute_set.each do | attribute |
        if attribute.options.include? :search_index
          field_type = attribute.options[:search_index][:as]
          schema.add_field(field_type, attribute.options[:name], attribute.options[:required])
        end
      end
      schema
    end
  end
end