module Cloudmunda
  module Configuration
    VALID_OPTIONS_KEYS = %i[env require logger timeout zeebe_url auth_url client_id client_secret audience graphql_url].freeze
    attr_accessor(*VALID_OPTIONS_KEYS)

    # Sets all configuration options to their default values when this module is extended.
    def self.extended(base)
      base.reset
    end

    def configure
      yield self
    end

    def config
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    # Resets all configuration options to the defaults.
    def reset
      @env = ENV["APP_ENV"] || ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
      @logger = Logger.new($stdout)
      @require = "."
      @timeout = 30
      @zeebe_url = ENV['ZEEBE_URL']
      @auth_url = ENV['ZEEBE_AUTHORIZATION_SERVER_URL']
      @client_id = ENV['ZEEBE_CLIENT_ID']
      @client_secret = ENV['ZEEBE_CLIENT_SECRET']
      @audience = ENV['ZEEBE_AUDIENCE']
      @graphql_url = ENV['GRAPHQL_URL']
    end
  end
end