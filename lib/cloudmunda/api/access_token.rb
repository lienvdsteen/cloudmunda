# frozen_string_literal: true

module Cloudmunda
  module API
    class AccessToken < Cloudmunda::API::OAuthResource
      def self.create(audience_url: Cloudmunda.audience)
        uri = Cloudmunda.auth_url
        payload = {
          "grant_type":"client_credentials",
          "audience": audience_url,
          "client_id": Cloudmunda.client_id,
          "client_secret": Cloudmunda.client_secret
        }

        create_by_uri(uri: uri, payload: payload)
      end
    end
  end
end
