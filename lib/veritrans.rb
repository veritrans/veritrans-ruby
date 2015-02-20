require 'veritrans/version'
require 'veritrans/core_extensions'
require 'veritrans/config'
require 'veritrans/client'
require 'veritrans/api'
require 'veritrans/result'

if defined?(::Rails)
  require 'veritrans/events'
end

module Veritrans
  extend Veritrans::Client
  extend Veritrans::Api

  class << self
    def config(&block)
      if block
        instance_eval(&block)
      else
        Veritrans::Config
      end
    end

    alias_method :setup, :config

    # General logger
    # for rails apps it's === Rails.logger
    # for non-rails apps it's logging to stdout
    def logger
      return @logger if @logger
      if defined?(Rails)
        Rails.logger
      else
        unless @log
          require 'logger'
          @log = Logger.new(STDOUT)
          @log.level = Logger::INFO
        end
        @log
      end
    end

    def logger=(value)
      @logger = value
    end

    # Logger to file, only important information
    # For rails apps it will write log to RAILS_ROOT/log/veritrans.log
    def file_logger
      if !@file_logger
        if defined?(Rails) && Rails.root
          @file_logger = Logger.new(Rails.root.join("log/veritrans.log").to_s)
        else
          @file_logger = Logger.new("/dev/null")
        end
      end

      @file_logger
    end

    def file_logger=(value)
      @file_logger = value
    end

    def events
      Veritrans::Events if defined?(Veritrans::Events)
    end

    def decode_notification_json(input)
      return Veritrans::Client._json_decode(input)
    end

  end
end
