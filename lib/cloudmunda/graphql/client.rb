# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'uri'
require 'base64'

module Cloudmunda
  module Graphql
    class Client
      def self.post(params = {})
        response = RestClient.post(Cloudmunda.graphql_url, params.to_json, headers.merge(content_headers))
        JSON.parse(response.body)
      end

      def self.headers
        access_token = Cloudmunda::API::AccessToken.create(audience_url: 'tasklist.camunda.io').access_token
        {
          authorization: "Bearer #{access_token}"
        }
      end

      def self.content_headers
        {
          'Content-Type': 'application/json'
        }
      end
    end
  end
end
