# Veritrans HTTP Client

require "base64"
require 'uri'
require 'excon'

class Veritrans
  module Client

    # If you using Rails then it will call ActiveSupport::JSON.encode
    # Otherwise JSON.pretty_generate
    def self._json_encode(params)
      if defined?(ActiveSupport) && defined?(ActiveSupport::JSON)
        ActiveSupport::JSON.encode(params)
      else
        require 'json' unless defined?(JSON)
        JSON.pretty_generate(params)
      end
    end

    def _json_encode(params)
      Veritrans::Client._json_encode(params)
    end

    # If you using Rails then it will call ActiveSupport::JSON.decode
    # Otherwise JSON.parse
    def self._json_decode(params)
      if defined?(ActiveSupport) && defined?(ActiveSupport::JSON)
        ActiveSupport::JSON.decode(params)
      else
        require 'json' unless defined?(JSON)
        JSON.parse(params)
      end
    end

    # This is proxy method for make_request to save request and response to logfile
    def request_with_logging(method, url, params, server_key = nil)
      short_url = url.sub(config.api_host, '')
      file_logger.info("Perform #{short_url} \nSending: " + _json_encode(params))

      result = make_request(method, url, params, server_key)

      if result.status_code < 300
        file_logger.info("Success #{short_url} \nGot: " + _json_encode(result.data) + "\n")
      else
        file_logger.warn("Failed #{short_url} \nGot: " + _json_encode(result.data) + "\n")
      end

      result
    end

    private

    def basic_auth_header(server_key = SERVER_KEY)
      key = Base64.strict_encode64(server_key + ":")
      "Basic #{key}"
    end

    def get(url, server_key = nil, params = {})
      make_request(:get, url, params, server_key)
    end

    def delete(url, params, server_key = nil)
      make_request(:delete, url, params, server_key)
    end

    def post(url, params, server_key = nil)
      make_request(:post, url, params, server_key)
    end

    def make_request(method, url, params, auth_header = nil)
      if !config.server_key || config.server_key == ''
        raise "Please add server_key to config/veritrans.yml"
      end

      server_key = auth_header.nil? ? config.server_key : auth_header

      method = method.to_s.upcase
      logger.info "Veritrans: #{method} #{url} #{_json_encode(params)}"
      #logger.info "Veritrans: Using server key: #{config.server_key}"
      #puts "Veritrans: #{method} #{url} #{_json_encode(params)}"

      default_options = config.http_options || {}

      # Add authentication and content type
      # Docs https://api-docs.midtrans.com/#http-s-header
      request_options = {
        :path => URI.parse(url).path,
        :headers => {
          :Authorization => basic_auth_header(server_key),
          :Accept => "application/json",
          :"Content-Type" => "application/json",
          :"User-Agent" => "Veritrans ruby gem #{Veritrans::VERSION}"
        }
      }

      if method == "GET"
        request_options[:query] = URI.encode_www_form(params)
      else
        request_options[:body] = _json_encode(params)
      end

      connection_options = {
        read_timeout: 120,
        write_timeout: 120,
        connect_timeout: 120
      }.merge(default_options)

      s_time = Time.now
      request = Excon.new(url, connection_options)

      response = request.send(method.downcase.to_sym, request_options)

      logger.info "Veritrans: got #{(Time.now - s_time).round(3)} sec #{response.status} #{response.body}"

      Result.new(response, url, request_options, Time.now - s_time)

    rescue Excon::Errors::SocketError => error
      logger.info "Veritrans: socket error, can not connect (#{error.message})"
      error_response = Excon::Response.new(
        body: '{"status_code": "500", "status_message": "Internal server error, no response from backend. Try again later"}',
        status: '500'
      )
      Veritrans::Result.new(error_response, url, request_options, Time.now - s_time)
    end

  end
end
