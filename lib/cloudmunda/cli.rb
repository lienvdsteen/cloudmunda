# frozen_string_literal: true

require 'singleton'
require 'optparse'
require 'fileutils'
require 'cloudmunda'
require 'cloudmunda/cli/launcher'

$stdout.sync = true

module Cloudmunda
  class CLI
    include Singleton

    attr_accessor :launcher

    def parse(argv = ARGV)
      parse_options(argv)
    end

    def run
      boot

      self_read, self_write = IO.pipe
      sigs = %w[INT TERM]
      sigs.each do |sig|
        trap sig do
          self_write.write("#{sig}\n")
        end
      rescue ArgumentError
        logger.warn "Signal #{sig} not supported"
      end

      launch(self_read)
    end

    private

    def parse_options(argv)
      option_parser.parse!(argv)
    end

    def option_parser
      OptionParser.new.tap do |p|
        p.on '-e', '--env ENV', 'Application environment' do |arg|
          config.env = arg
        end

        p.on '-i', '--client-id CLIENT_ID', 'Client ID' do |arg|
          config.client_id = arg
        end

        p.on '-r', '--require [PATH|DIR]', 'Location of Rails application with workers or file to require' do |arg|
          if !File.exist?(arg) ||
             (File.directory?(arg) && !File.exist?("#{arg}/config/application.rb"))
            raise ArgumentError, "#{arg} is not a ruby file nor a rails application"
          else
            config.require = arg
          end
        end

        p.on '-s', '--client-secret CLIENT_SECRET', 'Client Secret' do |arg|
          config.client_secret = arg
        end

        p.on '-u', '--zeebe-url ZEEBE_URL', 'Zeebe URL' do |arg|
          config.zeebe_url = arg
        end

        p.on '-U', '--zeebe-auth-url ZEEBE_AUTH_URL', 'Zeebe Authorization Server URL' do |arg|
          config.auth_url = arg
        end

        p.on '-a', '--audience URL', 'Zeebe Audience' do |arg|
          config.audience = arg
        end

        p.on '-T', '--use-access-token STRING', 'Zeebe Audience' do |arg|
          config.use_access_token = arg.to_s.downcase == 'true'
        end

        p.on '-t', '--timeout NUM', 'Shutdown timeout' do |arg|
          timeout = Integer(arg)
          raise ArgumentError, 'timeout must be a positive integer' if timeout <= 0

          config.timeout = timeout
        end

        # p.on "-v", "--verbose", "Print more verbose output" do |arg|
        #   ::Cloudmuna.logger.level = ::Logger::DEBUG
        # end

        p.on '-V', '--version', 'Print version and exit' do |_arg|
          puts "Cloudmunda #{::Cloudmunda::VERSION}"
          exit(0)
        end

        p.banner = 'Usage: cloudmunda [options]'
        p.on_tail '-h', '--help', 'Show help' do
          puts p

          exit(1)
        end
      end
    end

    def boot
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = config.env

      if File.directory?(config.require)
        require 'rails'
        raise 'Cloudmunda does not supports this version of Rails' if ::Rails::VERSION::MAJOR < 6

        require File.expand_path("#{config.require}/config/environment.rb")
        Dir[Rails.root.join('app/jobs/**/*.rb')].sort.each { |f| require f }

        logger.info "Booted Rails #{::Rails.version} application in #{config.env} environment"
      else
        require config.require
      end
    end

    def launch(self_read)
      @launcher = ::Cloudmunda::Launcher.new

      logger.info 'Starting processing, hit Ctrl-C to stop' if config.env == 'development' && $stdout.tty?

      begin
        launcher.start

        while (readable_io = IO.select([self_read]))
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue Interrupt
        logger.info 'Shutting down'
        launcher.stop
        logger.info 'Bye!'

        exit(0)
      end
    end

    def handle_signal(signal)
      handler = signal_handlers[signal]
      if handler
        handler.call(self)
      else
        logger.warn "No signal handler for #{signal}"
      end
    end

    def signal_handlers
      {
        'INT' => ->(_cli) { raise Interrupt },
        'TERM' => ->(_cli) { raise Interrupt }
      }
    end

    def config
      ::Cloudmunda
    end

    def logger
      ::Cloudmunda.logger
    end
  end
end
