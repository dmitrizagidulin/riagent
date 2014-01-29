# riagent

Ruby on Rails integration for RiakJson (Riak + Solr) Object Document Mapper framework

## Requirements
 - Ruby 1.9+
 - Riak build with [Riak Json](https://github.com/basho-labs/riak_json) and Solr/Yokozuna enabled 
   (see [Setup](https://github.com/basho-labs/riak_json#setup) section for instructions)
 - [riak_json](https://github.com/basho-labs/riak_json_ruby_client) Ruby Client gem installed locally
 - [riak_json-active_model](https://github.com/dmitrizagidulin/rj-activemodel) RiakJson Active Model gem installed locally

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
To run the tests

```
bundle exec rake test
```