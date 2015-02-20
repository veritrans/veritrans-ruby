require 'yaml'
require 'excon'

module Veritrans

  module Config
    extend self

    @api_host = "https://api.sandbox.veritrans.co.id"

    def client_key
      @client_key
    end

    def client_key=(value)
      @client_key = value
    end

    def server_key
      @server_key
    end

    def server_key=(value)
      @server_key = value
    end

    def api_host
      @api_host
    end

    def api_host=(value)
      @api_host = value
    end

    ##
    # This will override http request settings for api calls
    # Should be hash, it will be merged with connection options for every request
    #
    # Full list of options: https://github.com/excon/excon/blob/master/lib/excon/constants.rb
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