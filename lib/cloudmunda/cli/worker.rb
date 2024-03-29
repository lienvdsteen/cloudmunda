# frozen_string_literal: true

require 'json'

module Cloudmunda
  module Worker
    attr_accessor :client, :type, :max_jobs_to_activate, :poll_interval, :timeout, :variables

    def self.included(base)
      base.extend(ClassMethods)
      Cloudmunda.register_worker(base)
    end

    def initialize(client)
      @client = client
    end

    def complete_job(job, variables: {})
      logger.info "Completed processing job #{job.type} #{job.key}"
      client.complete_job(
        jobKey: job.key,
        variables: Hash(variables).to_json
      )
    end

    def fail_job(job, reason: '')
      logger.error "Failed processing job #{job.type} #{job.key}: #{reason}"
      client.fail_job(
        jobKey: job.key,
        retries: job.retries - 1,
        errorMessage: reason
      )
    rescue StandardError => e
      logger.error e.message
    end

    def logger
      ::Cloudmunda.logger
    end

    module ClassMethods
      # Sets the type of service task the worker should subscribe to.
      #
      # @example
      #   class MyWorker
      #     include ::Cloudmunda::Worker
      #     type "some-service-task-type"
      #   end
      #
      # @param [String] type
      # @return [String]
      def type(type)
        @type = type
      end

      # Returns the type of service task the worker should subscribe to.
      #
      # @return [String]
      def get_type
        @type
      end

      # Sets the maximum number of jobs to send to the worker for processing at once.
      # As jobs get completed by the worker, more jobs will be sent to the worker
      # but always within this limit.
      #
      # @example
      #   class MyWorker
      #     include ::Cloudmunda::Worker
      #     max_jobs_to_activate 5
      #   end
      #
      # @param [Integer] max_jobs_to_activate
      # @return [Integer]
      def max_jobs_to_activate(max_jobs_to_activate)
        @max_jobs_to_activate = max_jobs_to_activate
      end

      # Returns the maximum number of jobs to send to the worker for processing at once.
      # As jobs get completed by the worker, more jobs will be sent to the worker
      # but always within this limit.
      #
      # @return [Integer]
      def get_max_jobs_to_activate
        @max_jobs_to_activate || 1
      end

      # Sets the interval duration in seconds between polls to the broker.
      #
      # @example
      #   class MyWorker
      #     include ::Cloudmunda::Worker
      #     poll_interval 5
      #   end
      #
      # @param [Integer] poll_interval
      # @return [Integer]
      def poll_interval(poll_interval)
        @poll_interval = poll_interval
      end

      # Returns the interval duration in seconds between polls to the broker.
      #
      # @return [Integer]
      def get_poll_interval
        @poll_interval || 5
      end

      # Sets the time in seconds the worker has to process the job before
      # the broker consider it as expired and can schedule it to another worker.
      #
      # @example
      #   class MyWorker
      #     include ::Cloudmunda::Worker
      #     timeout 30
      #   end
      #
      # @param [Integer] timeout
      # @return [Integer]
      def timeout(timeout)
        @timeout = timeout
      end

      # Returns the time in seconds the worker has to process the job before
      # the broker consider it as expired and can schedule it to another worker.
      #
      # @return [Integer]
      def get_timeout
        @timeout || 30
      end

      # Sets the worker's variables to fetch from the broker when polling for new
      # jobs.
      #
      # @example
      #   class MyWorker
      #     include ::Cloudmunda::Worker
      #     variables [:foo, :bar]
      #   end
      #
      # @param [Array<String, Symbol>] variables
      # @return [Array<String, Symbol>]
      def variables(variables)
        @variables = variables
      end

      # Returns the worker's variables to fetch from the broker when polling for new
      # jobs.
      #
      # @return [Array<String, Symbol>]
      def get_variables_to_fetch
        @variables.to_a
      end

      # Returns the worker's name.
      #
      # @return [String]
      def get_name
        name = self.name.gsub(/::/, ':')
        name.gsub!(/([^A-Z:])([A-Z])/) { "#{Regexp.last_match(1)}_#{Regexp.last_match(2)}" }
        name.downcase
      end
    end
  end
end
