# riagent

Object Document Mapper for RiakJson (Riak + Solr), for use with Ruby on Rails 4 and Sinatra.

## Requirements
 - Ruby 1.9+
 - Riak build with [Riak Json](https://github.com/basho-labs/riak_json) and Solr/Yokozuna enabled 
   (see [Setup](https://github.com/basho-labs/riak_json#setup) section for instructions)
 - [RiakJson](https://github.com/basho-labs/riak_json_ruby_client) Ruby Client gem installed locally
 - [riagent-document](https://github.com/dmitrizagidulin/riagent-document) gem installed locally

## Motivation
*a.k.a. Why not just use a plain [riak_json client](https://github.com/basho-labs/riak_json_ruby_client) or a 
[riak-ruby-client](https://github.com/basho/riak-ruby-client)?*

A RiakJson or Riak client just answers the question "How do I store stuff in Riak?". 
In order to develop any non-toy application using Riak as a persistence layer, a developer must answer further questions:

 - How do I define my model objects, and how do I serialize them so I can store them in Riak?
 - What will my access patterns be? Plain Key/Value reads and writes, or will I need to perform queries?
 - How do I integrate painlessly with my framework of choice? (Ruby on Rails, Sinatra)

Riagent attempts to provide answers to those questions, to encode recommended best-practice Riak query patterns,
and in general to aid rapid application development by working with Riak's strenghts while respecting its limitations. 
It is intended as a spiritual successor to [Ripple](https://github.com/basho-labs/ripple).

#### Model Definition and Serialization
Riagent provides a model definition language that will be familiar to most Rails developers, via 
the [riagent-document](https://github.com/dmitrizagidulin/riagent-document) gem.

```ruby
include 'riagent-document'

class User
  include Riagent::ActiveDocument
  
  attribute :username, String
  attribute :email, String
  attribute :country, String, default: 'USA'
end
```

Riagent::ActiveDocument instances provide a rich set of functionality including attribute defaults, type coercions, 
conversion to and from JSON, search schema creation, easy persistence to Riak,
document embedding, and more. See the [riagent-document README](https://github.com/dmitrizagidulin/riagent-document)
for more details.

#### Advanced Riak K/V and Query Support
Reads and writes of single objects into Riak are easy (and have the benefit of being massively scalable, highly concurrent, and fault-tolerant).
But what about listing and querying? Every developer that gets past a Hello World get/put tutorial on Riak is soon faced with questions
about more advanced access patterns. How do I implement collections, and list things? How do I search or query on various attributes?
Should I use Secondary Indexes? What about Search/Solr integration? 

Riagent provides a set of high-level notations and functionality that allows developers create collections and associations on Riak,
either via plain K/V operations when possible, or via advanced mechanisms such as Solr/[RiakJson](https://github.com/basho-labs/riak_json)
queries when necessary.

#### Rails and Sinatra integration


## Installation
Add it to the Gemfile of your Rails app:

```ruby
gem 'riagent'
```

Run the install generator:
```bash
rails generate riagent:install
```

## Testing
First, set up the Riak config file for (and make sure it's pointing to a running Riak instance)

```
cp test/config/riak.yml.example test/config/riak.yml
```

To run the tests:

```
bundle exec rake test
```