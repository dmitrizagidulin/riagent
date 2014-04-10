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

module Riagent
  module Associations
    extend ActiveSupport::Concern
    
    module ClassMethods
      def has_many(name, options={})
        query_type = options[:using]
        target_class = options[:class]
        case query_type
        when :solr
          has_many_using_solr(name, target_class, query_type, options)
        else
          raise ArgumentError, ":using query type not supported"
        end
      end
      
      # Create a has_many association where the collection will be loaded
      # via RiakJson Solr queries.
      def has_many_using_solr(name, target_class, query_type, options)
        target_getter_method = "#{name}".to_sym
        
        # Create a <target name>_cache attribute accessors
        # These will be used to store the actual loaded collection
        target_cache_attribute = "#{name}_cache".to_sym
        attr_accessor target_cache_attribute
        
        # Create the getter method
        define_method(target_getter_method) do
          # First, check to see if the target collection has already been loaded/cached
#          cached_collection = send(target_cache_attribute)
#          if cached_collection.nil?
#            
#            source_key_value = send(:key)  # Get the source (parent) id
#            cached_collection = target_class.find(target_key)
#            send(target_setter_method, cached_collection)  # Cache the loaded target collection
#          end
#          cached_value
        end
        
        target_setter_method = "#{name}=".to_sym
        
        # Create the setter method=
        define_method(target_setter_method) do | target |
        end
      end
      
      def has_one(name, options={})
        target_key_attribute = "#{name}_key"
        target_class = options[:class]
        
        # Create a <target name>_key attribute, 
        attribute target_key_attribute, String, default: ''
        
        # Create a <target name>_cache attribute accessors
        # These will be used to store the actual instance of the target
        target_cache_attribute = "#{name}_cache".to_sym
        attr_accessor target_cache_attribute
          
        target_getter_method = "#{name}".to_sym
        target_setter_method = "#{name}=".to_sym
        
        # Create the setter method=
        define_method(target_setter_method) do | target |
          # Only assignments of the correct target class are allowed
          unless target.kind_of? target_class
            raise ArgumentError, "Invalid argument type #{target.class}, #{target_class} expected."
          end
          target_key = target ? target.key : nil
          attribute_setter = "#{target_key_attribute}=".to_sym
          send(attribute_setter, target_key)
          attribute_cache_getter = "#{target_cache_attribute}="
          send(attribute_cache_getter, target)
        end

        # Create the getter method
        define_method(target_getter_method) do
          # First, check to see if the target instance has already been loaded/cached
          cached_value = send(target_cache_attribute)
          if cached_value.nil?
            target_key = send(target_key_attribute)
            cached_value = target_class.find(target_key)
            send(target_setter_method, cached_value)  # Cache the loaded target instance
          end
          cached_value
        end
        
        # Create build_<target> method
        build_helper_method = "build_#{name}".to_sym
        define_method(build_helper_method) do | attributes |
          target_instance = target_class.new attributes
          target_instance.key = self.key # The target object gets the source's key by default
          send(target_setter_method, target_instance)
        end
      end
    end
  end
end