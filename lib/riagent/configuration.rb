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
  module Configuration
    def config
      @config ||= {}
    end

    def config=(value)
      @config = value
    end
    
    def config_for(environment=:development)
      if self.config.present?
        env_config = self.config[environment.to_s]
      else
        env_config = {
          'host' => ENV['RIAK_HOST'],
          'http_port' => ENV['RIAK_HTTP_PORT'],
          'pb_port' => ENV['RIAK_PB_PORT']
        }
      end
      env_config
    end
    
    # Initialize Riagent persistence clients for a given environment
    # Either called explicitly (see test/test_helper.rb for example usage)
    # or called by Rails through the 'riagent.configure_rails_initialization' initializer
    # in lib/railtie.rb
    def init_clients(environment=:development)
      self.init_riak_json_client(environment)
    end
    
    def init_riak_json_client(environment=:development)
      env_config = self.config_for(environment)
      client = RiakJson::Client.new(env_config['host'], env_config['http_port'])
      self.riak_json_client = client
    end
    
    def load_config_file(config_file_path)
      config_file = File.expand_path(config_file_path)
      config_hash = YAML.load(ERB.new(File.read(config_file)).result)
      self.config = config_hash
    end
    
    # @return [RiakJson::Client] The client for the current thread.
    def riak_json_client
      Thread.current[:riak_json_client] ||= nil
    end
  
    # Sets the client for the current thread.
    # @param [RiakJson::Client] value the client
    def riak_json_client=(value)
      Thread.current[:riak_json_client] = value
    end
  end
end