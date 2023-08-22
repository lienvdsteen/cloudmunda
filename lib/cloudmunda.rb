# frozen_string_literal: true

require 'concurrent'

require_relative 'cloudmunda/version'
require_relative 'cloudmunda/loggable'
require_relative 'cloudmunda/cli/worker'
require_relative 'cloudmunda/configuration'
require_relative 'cloudmunda/api'
require_relative 'cloudmunda/zeebe'

module Cloudmunda
  extend Configuration
  extend Loggable

  def self.client
    @client ||= ::Cloudmunda::Zeebe::Client.new
  end

  def self.register_worker(worker)
    workers << worker
  end

  def self.workers
    @workers ||= []
  end
end
