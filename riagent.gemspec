# coding: utf-8
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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riagent/version'

Gem::Specification.new do |spec|
  spec.name          = "riagent"
  spec.version       = Riagent::VERSION
  spec.authors       = ["Dmitri Zagidulin"]
  spec.email         = ["dzagidulin@gmail.com"]
  spec.summary       = %q{Rails integration for the Riak KV NoSQL database}
  spec.description   = %q{Provides Ruby on Rails integration for the Riak KV NoSQL database (plus Solr search)}
  spec.homepage      = "https://github.com/dmitrizagidulin/riagent"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "riak-client", "~> 2.2"
  spec.add_runtime_dependency "riagent-document", "0.0.2"
  spec.add_runtime_dependency "activemodel", "~> 4.2"
  spec.add_runtime_dependency "activesupport", "~> 4.2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.1"
  spec.add_development_dependency "minitest-spec-context"
end
