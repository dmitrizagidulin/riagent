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
      def has_one(name, options={})
        target_key_attribute = "#{name}_key"
        target_class = options[:class]
        
        # Create a <target name>_key attribute, 
        attribute target_key_attribute, String, default: lambda { | source, attribute | source.key }
        
        # Create a <target name>_cache attribute accessors
        # These will be used to store the actual instance of the target
        target_cache_attribute = "#{name}_cache".to_sym
        attr_accessor target_cache_attribute
          
        target_getter = "#{name}".to_sym
        target_setter_method = "#{name}=".to_sym
        
        # Create the setter method=
        define_method(target_setter_method) do | target |
          target_key = target ? target.key : nil
          attribute_setter = "#{target_key_attribute}=".to_sym
          send(attribute_setter, target_key)
          attribute_cache_getter = "#{target_cache_attribute}="
          send(attribute_cache_getter, target)
        end

        # Create the getter method
        define_method(target_getter) do
          # First, check to see if the target instance has already been loaded/cached
          cached_value = send(target_cache_attribute)
          if cached_value.nil?
            target_key = send(target_key_attribute)
            cached_value = target_class.find(target_key)
            send(target_setter_method, cached_value)  # Cache the loaded target instance
          end
          cached_value
        end
        
      end
    end
  end
end