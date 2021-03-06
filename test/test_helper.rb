## ------------------------------------------------------------------- 
## 
## Copyright (c) "2014-2015" Dmitri Zagidulin and Basho Technologies, Inc.
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

require 'minitest/autorun'
require 'minitest-spec-context'
require 'riagent'
require 'examples/models/address_book'
require 'examples/models/blog_post'
require 'examples/models/category'
require 'examples/models/contact'
require 'examples/models/user'
require 'examples/models/user_preference'

# Set this to silence "[deprecated] I18n.enforce_available_locales will default to true in the future." warnings
I18n.config.enforce_available_locales = true

# Load config file and set up the relevant clients for integration testing
Riak.disable_list_keys_warnings = true
Riagent.load_config_file('test/config/riak.yml')
Riagent.init_clients(:test)  # Set up the client for the test environment