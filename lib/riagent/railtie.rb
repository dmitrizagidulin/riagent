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

require 'rails/railtie'
require 'riak_json'

module Riagent
  # Railtie for Rails integration and initialization
  class Railtie < Rails::Railtie
    initializer "omnidoc.configure_rails_initialization" do
      config_file = Rails.root.join('config', 'riak.yml')
      if File.exist?(config_file)
        config = RiakJson::Client.load_config_file(config_file).with_indifferent_access
        env_config = config[Rails.env]
        Riagent.config = env_config
      end
    end
  end
end