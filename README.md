# riagent

Object Document Mapper for [Riak](http://basho.com/products/riak-kv/)
(including integration with Solr search), for use with Ruby on Rails 4 and
Sinatra.

## Requirements
 - Ruby 2+
 - [Riak](http://basho.com/products/riak-kv/) version 2.0 or later

## Motivation
*a.k.a. Why not just use a plain
[riak-ruby-client](https://github.com/basho/riak-ruby-client)?*

A Riak client just answers the question "How do I store stuff in Riak?".
In order to develop any non-toy application using Riak as a persistence layer,
a developer must answer further questions:

 - How do I define my model objects, and how do I serialize them so I can store
    them in Riak?
 - What will my access patterns be? Plain Key/Value reads and writes, or will I
    need to perform queries?
 - How do I integrate painlessly with my framework of choice? (Ruby on Rails,
     Sinatra)

Riagent attempts to provide answers to those questions, to encode recommended
best-practice Riak query patterns, and in general to aid rapid application
development by working with Riak's strengths while respecting its limitations.
It is intended as a spiritual successor to
[Ripple](https://github.com/basho-labs/ripple).

#### Model Definition and Serialization
Riagent provides a model definition language that will be familiar to most Rails
developers, via the
[riagent-document](https://github.com/dmitrizagidulin/riagent-document) gem.

```ruby
include 'riagent-document'

class User
  include Riagent::ActiveDocument

  attribute :username, String
  attribute :email, String
  attribute :country, String, default: 'USA'
end
```

Riagent::ActiveDocument instances provide a rich set of functionality including
attribute defaults, type coercions, conversion to and from JSON, search schema
creation, easy persistence to Riak, document embedding, and more. See the
[riagent-document README](https://github.com/dmitrizagidulin/riagent-document)
for more details.

#### Advanced Riak K/V and Query Support
Reads and writes of single objects into Riak are easy (and have the benefit of
being massively scalable, highly concurrent, and fault-tolerant). But what about
listing and querying? Every developer that gets past a Hello World get/put
tutorial on Riak is soon faced with questions about more advanced access
patterns. How do I implement collections, and list things? How do I search or
query on various attributes? Should I use Secondary Indexes? What about
Search/Solr integration?

Riagent provides a set of high-level notations and functionality that allows
developers create collections and associations on Riak, either via plain K/V
operations when possible, or via advanced mechanisms such as
Solr queries when necessary.

```ruby
class User
  include Riagent::ActiveDocument

  collection_type :riak_kv

  attribute :username, String
  attribute :email, String
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

 - Riagent provides client configuration and initialization, via the
    ```config/riak.yml``` file
 - Provides a simple Key/Value persistence layer with ```save()```,
    ```find()```, ```update()``` and ```destroy()``` methods.
 - ActiveDocument implements the ActiveModel API.
   (Specifically, passes the [ActiveModel Lint Test
    suite](http://api.rubyonrails.org/classes/ActiveModel/Lint/Tests.html))
 - Provides a full range of validations for each attribute.
 - Provides ```before_save``` / ```after_save``` type Callback functionality
 - Provides a custom Query capability (to Riak/Solr), for searches, range
    queries, aggregations and more

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

This creates a ```config/riak.yml``` file. Edit it to point to your running Riak
instance.

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
The usual array of CRUD type k/v operations is available to an ActiveDocument
model.

Create documents via ```save()``` and ```save!()```
```ruby
user = User.new({username: 'John', email: 'john@doe.com'})
# If you save without specifying a key, it generates a UUID key automatically
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

## Testing the Riagent gem
First, set up the Riak config file for (and make sure it's pointing to a running
Riak instance)

```
cp test/config/riak.yml.example test/config/riak.yml
```

The integration tests require that a Set bucket type be created, named `sets`:

```
riak-admin bucket-type create sets '{"props":{"datatype":"set"}}'
riak-admin bucket-type activate sets
```

To run the tests:

```
bundle exec rake test
```
