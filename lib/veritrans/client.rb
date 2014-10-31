# Veritrans HTTP Client

require "base64"
require 'uri'
require 'excon'

module Veritrans
  module Client
    extend self

    # Failback for activesupport
    def _json_encode(params)
      if defined?(ActiveSupport) && defined?(ActiveSupport::JSON)
        ActiveSupport::JSON.encode(params)
      else
        require 'json' unless defined?(JSON)
        JSON.generate(params)
      end
    end

    def _json_decode(params)
      if defined?(ActiveSupport) && defined?(ActiveSupport::JSON)
        ActiveSupport::JSON.decode(params)
      else
        require 'json' unless defined?(JSON)
        JSON.parse(params)
      end
    end


    private

    def basic_auth_header(server_key = SERVER_KEY)
      key = Base64.strict_encode64(server_key + ":")
      "Basic #{key}"
    end

    def get(url, params = {})
      make_request(url, :get, params)
    end

    def delete(url, params, auth_header = nil)
      make_request(url, :delete, params, auth_header)
    end

    def post(url, params, auth_header = nil)
      make_request(url, :post, params, auth_header)
    end

    def make_request(url, method, params, auth_header = nil)
      method = method.to_s.upcase
      logger.info "Veritrans: #{method} #{url} #{_json_encode(params)}"

      # Add authentication and content type
      # Docs http://docs.veritrans.co.id/sandbox/introduction.html
      options = {
        :body => _json_encode(params),
        :headers => {
          :Authorization => auth_header || basic_auth_header(config.server_key),
          :Accept => "application/json",
          :"Content-Type" => "application/json"
        }
      }

      if method == "GET"
        options.delete(:body)
        options[:query] = URI.encode_www_form(params)
      end

      s_time = Time.now
      request = Excon.new(url, read_timeout: 40, write_timeout: 40, connect_timeout: 40)

      response = request.send(method.downcase.to_sym, options.merge(path: URI.parse(url).path))

      logger.info "Veritrans: got #{Time.now - s_time}sec #{response.status} #{response.body}"

      Result.new(response, url, options, Time.now - s_time)

    rescue Excon::Errors::SocketError => error
      logger.info "PAPI: socket error, can not connect"
      error_response = Excon::Response.new(
        body: '{"status_code": "500", "status_message": "Internal server error, no response from backend. Try again later"}',
        status: '500'
      )
      Veritrans::Result.new(error_response, url, options, Time.now - s_time)
    end

  end
end
