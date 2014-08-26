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

require 'riagent'
require './test/examples/models/user'

puts "Seeding..."
# Load config file and set up the relevant clients for seeding test data
Riagent.load_config_file('test/config/riak.yml')
Riagent.init_clients(:test)  # Set up the client for the test environment

# Store the Solr indexing schema for the User model
User.save_solr_schema()

# Run these commands in the shell, in the riak/bin path:

# Create a 'sets' bucket type. (The RiakDTSetStrategy uses it to store key lists, etc)
# > riak-admin bucket-type create sets '{"props":{"datatype":"set"}}'
# > riak-admin bucket-type activate sets