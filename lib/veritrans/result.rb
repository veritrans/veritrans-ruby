module Veritrans
  class Result
    attr_reader :data
    attr_reader :status
    attr_reader :response

    def initialize(response, url, options, time)
      begin
        if url =~ %r{/v2/.+/transcript$}
          @data = {}
        else
          @data = Veritrans._json_decode(response.body)

          # Failback for Hash#symbolize_keys
          @data.keys.each do |key|
            @data[(key.to_sym rescue key) || key] = @data.delete(key)
          end
        end

      rescue => e
        Veritrans.logger.info "Error parsing papi response #{e.message}"
        Veritrans.logger.info e.backtrace.join("\n")
        @data = {}
      end

      @time = time
      @status = response.status
      @response = response
      @url = url
      @options = options
    end

    def success?
      @data[:status_code] == '200' || @data[:status_code] == '201'
    end

    # for VT-Link
    def created?
      @data[:status_code] == '201'
    end

    # Docs http://docs.veritrans.co.id/sandbox/status_code.html
    def status_code
      @data[:status_code].to_i
    end

    def status_message
      @data[:status_message]
    end

    def redirect_url
      @data[:redirect_url]
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
      "#<Veritrans::Result:#{object_id} ^^ http_status: #{@status} time: #{time_ms}ms ^^ data: #{data}>"
    end
  end
end