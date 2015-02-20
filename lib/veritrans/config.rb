require 'yaml'
require 'excon'

module Veritrans

  module Config
    extend self

    @api_host = "https://api.sandbox.veritrans.co.id"

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
    # Should be "https://api.sandbox.veritrans.co.id" or "https://api.veritrans.co.id"
    #
    # Default is "https://api.sandbox.veritrans.co.id"
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
    #   end
    #
    def load_config(filename)
      yml_file, yml_section = filename.to_s.split('#')
      config_data = YAML.load(File.read(yml_file))

      if defined?(Rails) && !yml_section
        yml_section = Rails.env.to_s
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

    def apply(hash)
      hash.each do |key, value|
        send(:"#{key}=", value)
      end
    end
  end

end