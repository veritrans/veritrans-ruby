require 'veritrans/version'
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

  autoload :Testing,    'veritrans/testing'
  autoload :TestingLib, 'veritrans/testing'
  autoload :CLI,        'veritrans/cli'
  autoload :Events,     'veritrans/events'

  class << self
    extend Forwardable

    def_delegators :instance, :logger, :logger=, :config, :setup, :file_logger, :file_logger=
    def_delegators :instance, :request_with_logging, :basic_auth_header, :get, :post, :delete, :make_request
    def_delegators :instance, :charge, :cancel, :approve, :status, :capture, :expire
    def_delegators :instance, :create_vtlink, :delete_vtlink, :inquiry_points, :create_widget_token, :create_snap_redirect_url, :create_snap_token
    def_delegators :instance, :checksum, :events

    # Shortcut for Veritrans::Events
    def events
      if defined?(ActiveSupport::Deprecation)
        ActiveSupport::Deprecation.warn("`Veritrans.events` is deprecated.  Please use `Veritrans::Events`.")
      else
        warn "`Veritrans.events` is deprecated.  Please use `Veritrans::Events`."
      end
      Veritrans::Events if defined?(Veritrans::Events)
    end

    # More safe json parser
    def decode_notification_json(input)
      return Veritrans::Client._json_decode(input)
    end

    def instance
      @instance ||= new
    end

  end

  def events
    self.class.events
  end

  # If you want to use multiple instances of Midtrans in your code (e.g. process payments in different accounts),
  # then you can create instance of Midtrans client
  #
  #   mt_client = Midtrans.new(
  #     server_key: "My-Different-Key",
  #     client_key: "...",
  #     api_host: "https://api.sandbox.midtrans.com", # default
  #     http_options: { }, # optional
  #     logger: Logger.new(STDOUT), # optional
  #     file_logger: Logger.new(STDOUT), # optional
  #   )
  #   mt_client.status("my-different-order-id")
  #
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

  # Midtrans configuration. Can be used as DSL and as object
  #
  # Use with block:
  #
  #   Midtrans.setup do
  #     config.load_yml "./midtrans.yml", Rails.env # load values from config
  #     # also can set one by one:
  #     config.server_key = "..."
  #     config.client_key = "..."
  #     config.api_host = "https://api.sandbox.midtrans.com" # (default)
  #   end
  #
  # Use as object:
  # 
  #   Midtrans.config.server_key
  #
  def config(&block)
    if block
      instance_eval(&block)
    else
      @config ||= Veritrans::Config.new
    end
  end
  alias_method :setup, :config

  # Calculate signature_key sha512 checksum for validating HTTP notifications
  #
  # Arguments:
  # [params]  A hash, should contain <tt>:order_id, :status_code, :gross_amount</tt>.
  #           Additional key <tt>:server_key</tt> is required if Midtrans.config.server_key is not set
  #
  # Example
  #
  #   Midtrans.checksum(order_id: "aa11", status_code: "200", gross_amount: 1000, server_key: "my-key")
  #   # => "5e00499b23a8932e833238b2f65dd4dd3d10451708c7ec4d93da69e8e7a2bac4f7f97f9f35a986a7d100d7fc58034e12..."
  #
  # Raises:
  # - <tt>ArgumentError</tt> when missing or invalid parameters
  #
  def checksum(params)
    require 'digest' unless defined?(Digest)

    params_sym = {}
    params.each do |key, value|
      params_sym[key.to_sym] = value
    end

    if (config.server_key.nil? || config.server_key == "") && params_sym[:server_key].nil?
      raise ArgumentError, "Server key is required. Please set Veritrans.config.server_key or :server_key key"
    end

    required = [:order_id, :status_code, :gross_amount]
    missing = required - params_sym.keys.select {|k| !!params_sym[k] }
    if missing.size > 0
      raise ArgumentError, "Missing required parameters: #{missing.map(&:inspect).join(", ")}"
    end

    if params_sym[:gross_amount].is_a?(Numeric)
      params_sym[:gross_amount] = "%0.2f" % params_sym[:gross_amount]
    elsif params_sym[:gross_amount].is_a?(String) && params_sym[:gross_amount] !~ /\d+\.\d\d$/
      raise ArgumentError, %{gross_amount has invalid format, should be a number or string with cents e.g "52.00" (given: #{params_sym[:gross_amount].inspect})}
    end

    seed = "#{params_sym[:order_id]}#{params_sym[:status_code]}" +
           "#{params_sym[:gross_amount]}#{params_sym[:server_key] || config.server_key}"

    logger.debug("checksum source: #{seed}")

    Digest::SHA2.new(512).hexdigest(seed)
  end

  # General Midtrans logger.
  # For rails apps it will try to use <tt>Rails.logger</tt>, for non-rails apps -- it print to stdout
  #
  #  Midtrans.logger.info "Processing payment"
  #
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

  # Set custom logger
  #
  #   Midtrans.logger = Logger.new("./log/midtrans.log")
  #
  def logger=(value)
    @logger = value
  end

  # Logger to file, only important information
  # For rails apps it will write log to RAILS_ROOT/log/veritrans.log
  def file_logger
    if !@file_logger
      require 'logger'
      begin
        if defined?(Rails) && Rails.root
          require 'fileutils'
          FileUtils.mkdir_p(Rails.root.join("log"))
          @file_logger = Logger.new(Rails.root.join("log/veritrans.log").to_s)
        else
          @file_logger = Logger.new("/dev/null")
        end
      rescue => error
        STDERR.puts "Failed to create Midtrans.file_logger, will use /dev/null"
        STDERR.puts "#{error.class}: #{error.message}"
        STDERR.puts error.backtrace
        @file_logger = Logger.new("/dev/null")
      end
    end

    @file_logger
  end

  # Set custom file_logger
  #
  #  Midtrans.file_logger = Logger.new("./log/midtrans.log")
  #
  def file_logger=(value)
    @file_logger = value
  end

end

# Alias constant for new name of company
Midtrans = Veritrans
