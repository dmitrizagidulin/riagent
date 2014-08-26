## -------------------------------------------------------------------
##
## Copyright (c) "2014" Dmitri Zagidulin
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
require "riagent/persistence/riak_kv_strategy"

module Riagent
  module Persistence
    class RiakDTSetStrategy < RiakKVStrategy
      # Return all the documents in the collection.
      # Uses Riak 2.0 CRDT Set Data type to keep track of collection key list
      # @param [Integer] results_limit Number of results returned (currently ignored)
      # @return [Array<Riagent::ActiveDocument>] List of ActiveDocument instances
      def all(results_limit)
      end
    end
  end
end