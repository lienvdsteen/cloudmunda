# frozen_string_literal: true

module Cloudmunda
  module Loggable
    def logger
      @logger || setup_logger
    end

    def logger=(logger)
      @logger = logger
    end

    def setup_logger
      @logger = Cloudmunda.config.logger
    end

    # Logs a deprecation warning to help users identify deprecated method usage
    # before Camunda 8.10 removes them.
    #
    # @param [String] method_name The name of the deprecated method
    # @param [String] replacement The name of the replacement method
    # @param [String] removal_version The version where the method will be removed
    def warn_deprecation(method_name, replacement, removal_version = '8.10')
      message = "[DEPRECATION] `#{method_name}` is deprecated and will be removed in Camunda #{removal_version}. "
      message += "Use `#{replacement}` instead."
      logger.warn(message)
    end
  end
end
