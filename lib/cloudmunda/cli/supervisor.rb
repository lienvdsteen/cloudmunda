require_relative 'processor'

module Cloudmunda
  class Supervisor
    def initialize
      @processors = []
    end

    def start
      @processors = workers.map do |worker_class|
        processor = ::Cloudmunda::Processor.new(worker_class: worker_class)
        processor.start
      end
    end

    def quiet
      logger.info "Terminating workers"
      @processors.each(&:stop)
    end

    def stop(timeout: ::Cloudmunda.timeout)
      quiet
      logger.info "Pausing #{timeout}s to allow workers to finish..."
      sleep timeout
    end

    private

    def workers
      ::Cloudmunda.workers.to_a
    end

    def logger
      ::Cloudmunda.logger
    end
  end
end
