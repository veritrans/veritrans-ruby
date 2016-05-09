class Veritrans
  class Result
    attr_reader :data
    attr_reader :status
    attr_reader :response
    attr_reader :request_options
    attr_reader :time
    attr_reader :url

    def initialize(response, url, request_options, time)
      begin
        if url =~ %r{/v2/.+/transcript$}
          @data = {}
        else
          @data = Veritrans::Client._json_decode(response.body)

          # Failback for Hash#symbolize_keys
          @data.keys.each do |key|
            @data[(key.to_sym rescue key) || key] = @data.delete(key)
          end
        end

      rescue => e
        Veritrans.logger.info "Error parsing Veritrans response #{e.message}"
        Veritrans.logger.info e.backtrace.join("\n")
        @data = {}
      end

      @time = time
      @status = response.status
      @response = response
      @url = url
      @request_options = request_options
    end

    def success?
      @data[:status_code] == '200' || @data[:status_code] == '201' || @data[:status_code] == '407'
    end

    # for VT-Link
    def created?
      @data[:status_code] == '201'
    end

    # Docs http://docs.veritrans.co.id/en/api/status_code.html
    def status_code
      @data[:status_code].to_i
    end

    def status_message
      @data[:status_message]
    end

    def redirect_url
      @data[:redirect_url]
    end

    def transaction_id
      @data[:transaction_id]
    end

    def messages
      if @data[:message].present?
        @data[:message].chomp(']').sub(/^\[/, '').split(',').map(&:strip)
      else
        []
      end
    end

    def body
      response.body
    end

    def method_missing(method_name, *args)
      if args.size == 0 && @data && @data.has_key?(method_name)
        return @data[method_name]
      else
        super
      end
    end

    def inspect
      time_ms = (@time * 1000).round
      data = @data.inspect.gsub(/:([^\s]+)=>/, "\\1: ")
      "#<#{self.class.to_s}:#{object_id} ^^ http_status: #{@status} time: #{time_ms}ms ^^ data: #{data}>"
    end
  end

  class SnapResult < Result
    def status_code
      @response.status.to_i
    end

    def token_id
      @data[:token_id]
    end

    def success?
      status_code == 200
    end
  end
end