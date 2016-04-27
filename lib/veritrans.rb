require 'veritrans/version'
require 'veritrans/core_extensions'
require 'veritrans/config'
require 'veritrans/client'
require 'veritrans/api'
require 'veritrans/result'

if defined?(::Rails)
  require 'veritrans/events'
end

class Veritrans
  include Veritrans::Client
  include Veritrans::Api

  class << self
    extend Forwardable

    def_delegators :instance, :logger, :logger=, :config, :setup, :file_logger, :file_logger=
    def_delegators :instance, :request_with_logging, :basic_auth_header, :get, :post, :delete, :make_request
    def_delegators :instance, :charge, :cancel, :approve, :status, :capture, :expire, :create_vtlink, :delete_vtlink, :inquiry_points

    def events
      Veritrans::Events if defined?(Veritrans::Events)
    end

    def decode_notification_json(input)
      return Veritrans::Client._json_decode(input)
    end

    def instance
      @instance ||= new
    end

  end

  def initialize(options = nil)
    if options && options[:logger]
      self.logger = options.delete(:logger)
      options.delete("logger")
    end

    if options && options[:file_logger]
      self.file_logger = options.delete(:file_logger)
      options.delete("file_logger")
    end

    if options
      @config = Veritrans::Config.new(options)
    end
  end

  def config(&block)
    if block
      instance_eval(&block)
    else
      @config ||= Veritrans::Config.new
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

end
