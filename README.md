# Cloudmunda

This Ruby gem makes it easier to connect your Ruby (on Rails) app with Camunda Cloud. 🎉 

The following is included:
- Ruby workers for Zeebe
- API wrapper for Camunda Cloud
- graphQL wrapper Usertasks

To use this library you need:

* a [Camunda Cloud Account](https://accounts.cloud.camunda.io/signup)
* your [Camunda client connection credentials](https://docs.camunda.io/docs/guides/getting-started/setup-client-connection-credentials/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloudmunda'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cloudmunda

### Rails applications

If you're using this gem with a rails application, you could create a `config/initializers/cloudmunda.rb` file and add
the following:

```ruby
Cloudmunda.configure do |config|
  config.env = ENV['APP_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  config.logger = Logger.new($stdout)
  config.timeout = 30
  config.client_id = ENV['ZEEBE_CLIENT_ID']
  config.client_secret = ENV['ZEEBE_CLIENT_SECRET']
  config.zeebe_url = ENV['ZEEBE_URL']
  config.auth_url = ENV['ZEEBE_AUTHORIZATION_SERVER_URL']
  config.audience = ENV['ZEEBE_AUDIENCE']
  config.graphql_url = ENV['GRAPHQL_URL']
end
```

The values listed above are the default values that you can override.

## Example Usage

This section will explain the usage as you were using a Rails application, but steps should be very similar within plain
Ruby apps or any other frameworks out there. Feel free to create an issue or PR if additional items are needed.

The idea of the example is that when a certain webhook comes in, a Slack message is sent. This might look like a bit
of overhead to use a business process engine for this, but it's just to show how the library works. Since we're 
communicating with Slack, you'd need a Slack workspace. You can also change the code in the example to send an email or
just write something in the logs.

You can find all the code [here](https://github.com/lienvdsteen/cloudmunda-demo).

### Add Slack and Cloudmunda gem
In your Gemfile add this line

```ruby
gem 'cloudmunda'
gem 'slack-ruby-client' # this is just for our example 
```

Then run

```shell
bundle install
```

As said above, create a initializer file so that whenever you are interacting with them gem you have the right settings set:

```shell
touch config/initializers/cloudmunda.rb
touch config/initializers/slack.rb # again, this is just for our example
```

Then open the `cloudmunda.rb` file and copy the following in it:

```ruby
Cloudmunda.configure do |config|
  config.env = ENV['APP_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  config.logger = Logger.new($stdout)
  config.timeout = 30
  config.client_id = ENV['ZEEBE_CLIENT_ID']
  config.client_secret = ENV['ZEEBE_CLIENT_SECRET']
  config.zeebe_url = ENV['ZEEBE_URL']
  config.auth_url = ENV['ZEEBE_AUTHORIZATION_SERVER_URL']
  config.audience = ENV['ZEEBE_AUDIENCE']
  config.graphql_url = ENV['GRAPHQL_URL']
end
```

Then open the `slack.rb` file and copy the following

```ruby
Slack.configure do |config|
  config.token = ENV['SLACK_OAUTH_TOKEN']
end
```

Note: this assumes you're using ENV variables, you can of course edit this to use something like `Settings.key` or 
how you prefer it. Just make sure not to publish your secrets.

### Deploy the diagram to your Camunda Cloud cluster
You can either import the [bpmn model example](/diagrams/demo.bpmn) as a diagram in your Camunda Cloud and 
use the UI to deploy or you can start a console (`rails console`) and deploy the diagram with the gem.

```ruby
Cloudmunda.client.deploy_process(processes: [name: "demo", definition: File.read('diagrams/demo.bpmn')])
```

### Create a worker

In `app/jobs` create a new file `demo_worker_job.rb` and copy paste the following:

```ruby
class DemoWorkerJob
  include ::Cloudmunda::Worker

  type 'webhook-slack-announce'
  max_jobs_to_activate 20
  poll_interval 1
  timeout 45

  attr_reader :variables

  def process(job)
    slack_client.chat_postMessage(channel: '#general', text: 'a message', as_user: true)
  end

  private

  def slack_client
    @slack_client ||= ::Slack::Web::Client.new
  end
end
```

### Setup the "webhook" 
Add the following to your `routes.rb` file `get 'webhook/received', to: 'webhook#received'` and then create a file 
`webhooks_controller.rb` in the controllers directory and copy paste the following:

```ruby
class WebhookController < ApplicationController
  def received
    Cloudmunda.client.create_process_instance(
      bpmnProcessId: 'cloudmunda-demo',
      version: 1,
      variables: {text: "hello"}.to_json
    )

    head :ok
  end
end
```

#### Run everything

Now everything should be able to execute. Lets start your rails server and then in another terminal tab run the following:

````ruby
bundle exec cloudmunda \
--require .
--client-id $ZEEBE_CLIENT_ID \
--client-secret $ZEEBE_CLIENT_SECRET \
--zeebe-url $ZEEBE_URL \
--zeebe-auth-url $ZEEBE_AUTHORIZATION_SERVER_URL \
--audience $ZEEBE_AUDIENCE
````

Then navigate to `localhost:3000/webhook/received`, what will happen is the following:
1. It goes to the `received` endpoint in the `WebhookController`
2. Here a new process instance is created on Camunda Cloud
3. This will then trigger the next step in the diagram, which is the service task
4. Through the grpc protocol our worker is linked with this service task and will be executed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cloudmunda. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/cloudmunda/blob/main/CODE_OF_CONDUCT.md).
Looking for:
- unit testing: currently nothing is tested
- additional API endpoints
- additional graphQL endpoints
- general improvements

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cloudmunda project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cloudmunda/blob/main/CODE_OF_CONDUCT.md).

## Credits

This gem is build on top of what [@gottfrois](https://github.com/gottfrois/) had build in his [beez](https://github.com/gottfrois/beez) 
gem. Everything in this gem related to the Ruby workers is a taken from that gem. 👏 Cloudmunda would **not** be 
possible without this.
