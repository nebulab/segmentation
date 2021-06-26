# Segmentation

Segmentation is a lightweight SDK that makes it easier to implement a full-stack 
[Segment](https://segment.com) integration in your Ruby on Rails application.

Segmentation aims to solve a few common problems when integrating Segment in a Rails application:

- Different Segment destinations require different keys in your payload. If you don't send these,
  your destinations will not work correctly. Segmentation provides a thin layer for abstracting the
  requirements of each destination.
- Sometimes, you need to track an event even though your user is not present on the page. When this
  happens, you may still need to include certain data about the user that's only available when the
  user is present. Segmentation allows you to store this data to use it at a later stage in a
  completely transparent way.
- While backend tracking is more precise, frontend tracking is richer. Segmentation allows you to
  get the best of both worlds by initiating the tracking from the backend and completing it on the
  frontend.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'segmentation'
```

And then execute:

```console
$ bundle
```

Next, run the install generator:

```console
$ rails g segmentation:install
```

This will generate a starting configuration at `config/initializer/segmentation.rb` and inject the
Segmentation controller helpers into `ApplicationController`. Make sure to review and adjust the
defaults according to your needs!

The last step is to render the JS code needed to load Segment and Segmentation. Add this to head
of your Rails layout:

```html
<!DOCTYPE html>
<html>
  <head>
    <%= segmentation_js_tag %>
    <!-- ... -->
  </head>

  <!-- ... -->
</html>
```

## Architecture

Segmentation revolves around four basic concepts:

- **Client:** it exposes the public-facing Segmentation API and allows you identify users and track
  events. The Segmentation client wraps any compatible Segment client (e.g., [analytics-ruby](https://github.com/segmentio/analytics-ruby)
  or [SimpleSegment](https://github.com/whatthewhat/simple_segment)) and matches its API 1:1, so
  that you can easily swap your old Segment client for the Segmentation client with no changes.
- **Context:** it contains all the information about the current request, anonymous ID and current
  user. It also abstracts some of the complexity of dealing with storages and destinations.
- **Storage:** it allows you to store the user's analytics metadata so that it can be used when
  tracking off-site events. An ActiveRecord adapter and a null adapter are provided out of the box,
  but you can very easily implement your own (e.g., Redis).
- **Destinations:** they abstract the complexity of dealing with different Segment destinations by
  enriching the event payload with the specific properties needed by each destination.

### Implementing your own destinations

Segment supports hundreds of different destinations, and it would be impossible for Segmentation to
keep up with the complexity of integrating with each destination. Instead, Segmentation provides a
simple API for abstracting the logic behind each destination and leaves it up to you to implement
the destinations you need.

For example, the [Facebook Pixel destination](https://segment.com/docs/connections/destinations/catalog/facebook-pixel/)
in Segment works best when you always pass the user's IP, user agent and the values of the user's
`_fbc` and `_fbp` cookies. This kind of information is obviously not available when you're tracking
an event outside of the request's lifecycle, so Segmentation allows you to store it when the user is
present and automatically retrieve it when tracking events for that user.

Here's what the Facebook Pixel destination might look like:

```ruby
class FacebookPixelDestination < Segmentation::Destination
  # Accepts a Rails request and returns the fields
  # to store on the configured storage adapter.
  def fields_from_request(request)
    {}.tap do |fields|
      if request
        fields[:ip] = request.remote_ip
        fields[:userAgent] = request.user_agent

        fields[:fbc] = request.cookies['_fbc'] if request.cookies['_fbc'].present?
        fields[:fbp] = request.cookies['_fbp'] if request.cookies['_fbp'].present?
      end
    end
  end

  # Accepts the fields stored on the current user and
  # returns the properties to enrich the context with.
  def context_from_fields(fields)
    {
      ip: fields[:ip],
      userAgent: fields[:userAgent],
    }.compact
  end

  # Accepts the fields stored on the current user and
  # returns the properties to enrich the event properties with.
  def properties_from_fields(fields)
    {
      fbc: fields[:fbc],
      fbp: fields[:fbp],
    }.compact
  end
end
```

In order to use your destination, you need to tell Segmentation it exists:

```ruby
# config/initializers/segmentation.rb
Segmentation.configure do |config|
  # ...

  config.destinations = [FacebookPixelDestination.new]
end
```

That's all you need! Now, Segmentation will store the latest version of the fields whenever the user
makes an authenticated request in your app, and it will include them when the you track an event for
that user.

### Implementing your own storage

Out of the box, Segmentation ships with two storage adapters: `ActiveRecordStorage`, which can be
used to store fields on your user's record in the DB, and `NullStorage`, which can be used as a
fallback when the user is not authenticated and therefore you cannot store any fields for them.

If you want to implement a custom storage, you can easily do it. Here's what a Redis storage might
look like, for example:

```ruby
class RedisStorage < Storage
  attr_reader :redis

  def initialize(redis)
    @redis = redis
  end

  def read(user)
    JSON.parse(redis.get("segmentation-fields/#{user.id}")).with_indifferent_access
  end

  def write(user, fields)
    redis.set("segmentation-fields/#{user.id}", JSON.dump(fields)).with_indifferent_access
  end
end
```

Finally, tell Segmentation to use your new storage:

```ruby
# config/initializers/segmentation.rb
Segmentation.configure do |config|
  # ...

  config.storage_builder = proc do |user|
    if user
      # If the user is authenticated, store their data in Redis.
      RedisStorage.new(Redis.new)
    else
      # If the user is a guest, don't attempt to store their data.
      Segmentation::Storages::NullStorage.new
    end
  end
end
```

Remember that your `user` object might be `nil`! Your storage either needs to play nice with that
case, or you need to fall back to the `NullStorage` in that case.

## Usage

### Identifying users

If you include the `Segmentation::ControllerHelpers` module in your base controller, Segmentation
will automatically identify your user upon each authenticated request!

You can still identify users manually by calling `Segmentation::Client#identify` if needed.

### Tracking events

#### Tracking from a controller

The most common way to track an event in Segment is to do it from a controller. When you track
events from a controller, Segmentation already has all the context it needs to enrich the event
payload with your user's traits and destinations.

To track an event from a controller, call `#segmentation_server_track(event, properties, options)`:

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def create
    # ...

    segmentation_server_track 'Post Created', {
      title: @post.title,
      # ...
    }
  end
end
```

### Tracking from outside a controller

Sometimes, you may want to track Segment events from outside a controller. This may be the case if
you're performing an action on behalf of a user who's not present on the page anymore (e.g., the
user initiated the action, but you're executing it in a background job).

To track an event from outside a controller, you'll need to build your own Segmentation context and
client:

```ruby
# app/services/create_post.rb
class CreatePost
  def call(...)
    # ...
    
    context = Segmentation::Context.new(user: post.user)
    segmentation = Segmentation::Client.new(context)
      
    segmentation.track('Post Created', {
      title: post.title
    })
  end
end
```

#### Tracking via JS

> NOTE: If your user is blocking tracking snippets through an extension, this method will still fail
> to track the events you initiate from the backend!

A third option is to initiate the tracking from the backend, but execute it in the frontend. This
is useful when you want the event payload to be enriched with data that's only available on the
frontend.

To track an event via JS, call `#segmentation_client_track(event, properties, options)`:

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def create
    # ...

    segmentation_client_track 'Post Created', {
      title: @post.title,
      # ...
    }
  end
end
```

Under the hood, Segmentation will store the event data in a Base64-encoded JSON cookie. On the next
page load, Segmentation will read the cookie and track any events it contains via JS.

## Testing

If you want to test that the right `identify` and `track` calls are being sent, you can use the
Segmentation testing backend and RSpec matchers.

First of all, add this to your `spec/rails_helper.rb`:

```ruby
require "segmentation/testing/backend"
require "segmentation/testing/rspec"

RSpec.configure do |config|
  config.include Segmentation::Testing::RSpec
  
  config.before do
    Segmentation.config.backend = Segmentation::Testing::Backend.new
  end
end
```

You can then do the following in your tests to assert `#identify` calls:

```ruby
# run some code that identifies the user... 

expect(Segmentation).to have_identified(traits: a_hash_including({ first_name: 'John' }))
```

You can also assert `#track` calls:

```ruby
# run some code that tracks an event...

expect(Segmentation).to have_tracked(
  event: 'Order Completed',
  properties: a_hash_including(total: 61.0),
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which
will create a git tag for the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nebulab/segmentation.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
