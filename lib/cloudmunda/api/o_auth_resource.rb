# frozen_string_literal: true

require 'ostruct'

module Cloudmunda
  module API
    class OAuthResource < OpenStruct
      def self.create_by_uri(uri:, payload:)
        raw_item = Cloudmunda::API::Client.post(uri, payload)
        raw_item = {} if raw_item == ''
        new(raw_item)
      end
    end
  end
end
