# frozen_string_literal: true

module Cloudmunda
  module API
    class AccessToken < Cloudmunda::API::OAuthResource
      def self.create
        uri = Cloudmunda.auth_url
        payload = {
          grant_type: 'client_credentials',
          audience: Cloudmunda.audience,
          client_id: Cloudmunda.client_id,
          client_secret: Cloudmunda.client_secret
        }

        create_by_uri(uri: uri, payload: payload)
      end
    end
  end
end
