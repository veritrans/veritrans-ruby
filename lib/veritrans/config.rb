require 'yaml'
require 'excon'
require 'erb'

class Veritrans

  class Config

    def initialize(options = nil)
      @api_host = "https://api.sandbox.midtrans.com"
      apply(options) if options
    end

    ##
    # Merhcant's Client key, used to make getToken request. (only for VT-Direct)
    #
    # Can be found in merchant portal: Settings -> Access Keys
    #
    def client_key=(value)
      @client_key = value
    end

    def client_key
      @client_key
    end

    ##
    # Merhcant's Server key, used to sign every http API call.
    #
    # Can be found in merchant portal: Settings -> Access Keys
    #
    def server_key=(value)
      @server_key = value
    end

    def server_key
      @server_key
    end

    ##
    # API Server hostname, this allow to switch between production and sandbox
    #
    # Should be "https://api.sandbox.midtrans.com" or "https://api.midtrans.com"
    #
    # Default is "https://api.sandbox.midtrans.com"
    #
    def api_host=(value)
      @api_host = value
    end

    def api_host
      @api_host
    end

    ##
    # This will override http request settings for api calls.
    # http_options should be hash, it will be merged with connection options for every request.
    #
    # Full list of options: https://github.com/excon/excon/blob/master/lib/excon/constants.rb
    #
    # For unsupported key it will raise ArgumentError
    #
    #   Veritrans.config.http_options = {tcp_nodelay: true, ssl_version: 'TLSv1'}
    #
    def http_options=(options)
      unless options.is_a?(Hash)
        raise ArgumentError, "http_options should be a hash"
      end

      # Validate allowed keys
      diff = options.keys.map(&:to_sym) - Excon::VALID_CONNECTION_KEYS
      if diff.size > 0
        raise ArgumentError,
              "http_options contain unsupported keys: #{diff.inspect}\n" +
                "Supported keys are: #{Excon::VALID_CONNECTION_KEYS.inspect}"
      end

      @http_options = options
    end

    def idempotency_key
      @idempotency_key
    end

    def append_notif_url
      @append_notif_url
    end

    def override_notif_url
      @override_notif_url
    end

    def http_options
      @http_options
    end

    ##
    # Loads YAML file and assign config values
    #
    # Supports #section in filename to choose one section.
    # If you are using Rails, it will try to use Rails.env as a section name
    #
    # Available config keys: server_key, client_key, api_host, http_options
    #
    #   Veritrans.setup do
    #     config.load_yml "#{Rails.root.to_s}/config/veritrans.yml#development"
    #     # or
    #     config.load_yml "#{Rails.root.to_s}/config/veritrans.yml", :development
    #   end
    #
    def load_config(filename, yml_section = nil)
      yml_file, file_yml_section = filename.to_s.split('#')
      config_data = YAML.load(ERB.new(File.read(yml_file)).result)

      yml_section ||= file_yml_section
      if defined?(Rails) && !yml_section
        yml_section = Rails.env.to_s
      end

      if yml_section && !config_data.has_key?(yml_section)
        STDERR.puts "Veritrans: Can not find section #{yml_section.inspect} in file #{yml_file}"
        STDERR.puts "           Available sections: #{config_data.keys}"

        if config_data['development'] && config_data['development']['server_key']
          new_section = 'development'
        end

        first_key = config_data.keys.first
        if config_data[first_key]['server_key']
          new_section = first_key
        end

        if new_section
          STDERR.puts "Veritrans: Using first section #{new_section.inspect}"
          yml_section = new_section
        end
      end

      apply(yml_section ? config_data[yml_section] : config_data)
    end

    alias :load_yml :load_config

    def inspect
      "<Veritrans::Config " +
        "@api_host=#{@api_host.inspect} " +
        "@server_key=#{@server_key.inspect} " +
        "@client_key=#{@client_key.inspect} " +
        "@http_options=#{@http_options.inspect}>"
    end

    private

    AVAILABLE_KEYS = [:server_key, :client_key, :api_host, :http_options]

    def apply(hash)
      hash.each do |key, value|
        unless AVAILABLE_KEYS.include?(key.to_s.to_sym)
          raise ArgumentError, "Unknown option #{key.inspect}, available keys: #{AVAILABLE_KEYS.map(&:inspect).join(", ")}"
        end
        send(:"#{key}=", value)
      end
    end
  end

end