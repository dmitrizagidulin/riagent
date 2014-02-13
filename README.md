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

```ruby
class User
  include Riagent::ActiveDocument
  
  collection_type :riak_json  # Persist to a RiakJson::Collection
  
  attribute :username, String, search_index: { as: :text }
  attribute :email, String, search_index: { as: :string }
  attribute :language, String, default: 'en'
  
  # Associations
  has_one :email_preference, :class => EmailPreference
  has_many :posts, :class => BlogPost, :using => :solr
  
  # Validations
  validates_presence_of :username
end
```

#### Rails and Sinatra integration
Riagent and ActiveDocuments are integrated into the usual Rails workflow. 

 - Riagent provides client configuration and initialization, via the ```config/riak.yml``` file
 - Provides a simple Key/Value persistence layer with ```save()```, ```find()```, ```update()``` and ```destroy()``` methods.
 - ActiveDocument implements the ActiveModel API.
   (Specifically, passes the [ActiveModel Lint Test suite](http://api.rubyonrails.org/classes/ActiveModel/Lint/Tests.html))
 - Provides a full range of validations for each attribute.
 - Provides ```before_save``` / ```after_save``` type Callback functionality
 - Provides a custom Query capability (to Riak/Solr), for searches, range queries, aggregations and more
 - Derives RiakJson/Solr search schemas from annotated document attributes (see Schemas below)

## Usage
### Adding Riagent to a Rails App
Add it to the Gemfile of your Rails app:

```ruby
gem 'riagent'
```

Run the install generator:
```bash
rails generate riagent:install
```

This creates a ```config/riak.yml``` file. Edit it to point to your running Riak instance.

### Controller and View helpers
Since they implement the ActiveModel API, when you use ActiveDocuments in 
a Rails model, the usual ```link_to```/route-based helpers work:
```erb
# In a user view file
<%= link_to @user.username, @user %> # => <a href="/users/EmuVX4kFHxxvlUVJj5TmPGgGPjP">HieronymusBosch</a>
<%= link_to 'Edit', edit_user_path(@user) %>  # => <a href="/users/EmuVX4kFHxxvlUVJj5TmPGgGPjP/edit">Edit</a>
# In a controller
redirect_to users_url
```

### Validations
ActiveDocument supports the full range of [ActiveModel validations](http://api.rubyonrails.org/classes/ActiveModel/Validations.html)

```ruby
# Try saving an invalid document
new_user = User.new
new_user.valid?  # => false
puts user.errors.messages  # => {:username=>["can't be blank"]}
new_user.save  # => false (does not actually save, since document not valid)
new_user.save!  # => raises Riagent::InvalidDocumentError exception

# Now make it valid
new_user.username = 'HieronymusBosch'
new_user.valid?  # => true
new_user.save  # => saves and loads the generated key into document
new_user.key  # => 'EmuVX4kFHxxvlUVJj5TmPGgGPjP'
```

### Key/Value Persistence
The usual array of CRUD type k/v operations is available to an ActiveDocument model.

Create documents via ```save()``` and ```save!()```
```ruby
user = User.new({username: 'John', email: 'john@doe.com'})
# If you save without specifying a key, RiakJson generates a UUID type key automatically
user.save  # => 'EmuVX4kFHxxvlUVJj5TmPGgGPjP'
```

To load a document by key, use ```find()```:

```ruby
user = User.find('EmuVX4kFHxxvlUVJj5TmPGgGPjP')
```

Update and Delete work in a similar fashion
```ruby
user.username = 'New Name'
user.update  # update!() is also available
user.destroy  # deletes the document
```

### Callbacks
ActiveDocument currently supports ```before_*``` and ```after_*``` [callbacks](http://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html) 
for the following events:
```[:create, :update, :save, :destroy]```

### Search and Querying
See the Querying sections of [RJ Ruby Client](https://github.com/basho-labs/riak_json_ruby_client#querying-riakjson---find_one-and-find)
and [RiakJson itself](https://github.com/basho-labs/riak_json/blob/master/docs/query.md)
```ruby
# All matching instances
us_users = User.where({ country: 'USA' })   # => array of US user instances
# One instance (the first)
user = User.find_one({ username: 'HieronymusBosch' })
```

## Search Schema Definition
RiakJson uses Solr/Yokozuna to provide indexing and search capability for its collections. 
If you do not specify a collection schema explicitly, RiakJson creates one when you insert the first document to that collection 
(it [infers the schema](https://github.com/basho-labs/riak_json/blob/master/docs/architecture.md#inferred-schemas) 
based on the basic data types of the field values in the JSON).
However, if you do not want to use this default schema behavior (for example, because RJ tries to index all of the fields), 
you can define and set a collection schema yourself, using RJ Ruby Client's [schema administration](https://github.com/basho-labs/riak_json_ruby_client#schema-administration) 
API.

To make the process of schema definition even easier for developers, ActiveDocument provides the ```search_index``` attribute
option. This annotation allows you to specify which document fields you want added to your search schema, as well as the 
Solr field type that will be used to index it.

For example, the following model:
```ruby
class User
  include RiakJson::ActiveDocument
  
  attribute :username, String, required: true, search_index: { :as => :text }
  attribute :email, String, search_index: { :as => :string }
  attribute :country, String, default: 'USA'
end
```
will enable you to construct the following schema:
```ruby
User.schema   # =>
#   [{
#     :name => "username",
#     :type => "text",
#     :require => true
#    }, {
#     :name => "email",
#     :type => "string",
#     :require => false
#    }
# ]
#   # Note that 'country' is not included in this schema, and so will not be indexed.
```

### Schema Administration
Note that if you use the ```search_index``` attribute annotations above, you will have to explicitly 
notify RiakJson of your intent to save the schema. You will have to call the ```set_schema()``` collection
method before you start inserting documents (for example, in a ```db:setup``` Rake task).

```ruby
User.collection.set_schema(User.schema)
```

## Testing the Riagent gem
First, set up the Riak config file for (and make sure it's pointing to a running Riak instance)

```
cp test/config/riak.yml.example test/config/riak.yml
```

To run the tests:

```
bundle exec rake test
```