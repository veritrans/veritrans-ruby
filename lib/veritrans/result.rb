class Veritrans
  # Midtrans response object, a wrapper for raw response object plus helper methods
  #
  # Usual response body for Midtrans.charge or Midtrans.status will look like this:
  #
  #   {
  #     "status_code": "200",
  #     "status_message": "Success, Mandiri Clickpay transaction is successful",
  #     "transaction_id": "d788e503-3fab-4296-9c10-83b107324cb9",
  #     "order_id": "2016-11-14 11:54:03 +0800",
  #     "gross_amount": "10000.00",
  #     "payment_type": "mandiri_clickpay",
  #     "transaction_time": "2016-11-14 10:54:02",
  #     "transaction_status": "settlement",
  #     "fraud_status": "accept",
  #     "approval_code": "1479095646260",
  #     "masked_card": "411111-1111"
  #   }
  #
  # Result object can be used like this:
  #
  #   result.success?    # => true
  #   result.status_code # => 200
  #   result.transaction_status # => "settlement"
  #   result.fraud_status # => "accept"
  #   result.approval_code # => "1479095646260"
  #   result.masked_card # => "411111-1111"
  #   
  #   result.data # => {:status_code => "200", :status_message => "Success, Mandiri ..."} # add data as hash
  #   result.time # => 1.3501
  #
  class Result
    # Response body parsed as hash
    attr_reader :data
    # HTTP status code, should always be 200
    attr_reader :status
    # Excon::Response object
    attr_reader :response
    # Request options, a hash with :path, :method, :headers, :body
    attr_reader :request_options
    # HTTP request time, a Float
    attr_reader :time
    # Request full URL, e.g. "https://api.sandbox.midtrans.com/v2/charge"
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

    # Return whenever transaction is successful, based on <tt>status_code</tt>
    def success?
      @data[:status_code] == '200' || @data[:status_code] == '201' || @data[:status_code] == '407'
    end

    # Return if VT-Link page was created
    def created?
      @data[:status_code] == '201'
    end

    # Return <tt>"status_code"</tt> field of response
    # Docs https://api-docs.midtrans.com/#status-code
    def status_code
      @data[:status_code].to_i
    end

    # Return <tt>"status_message"</tt> field of response
    def status_message
      @data[:status_message]
    end

    # Return <tt>"redirect_url"</tt> field of response
    def redirect_url
      @data[:redirect_url]
    end

    # Return <tt>"transaction_id"</tt> field of response
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

    # Raw response body as String
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
      "#<#{self.class.to_s}:#{object_id} ^^ status: #{@status} time: #{time_ms}ms ^^ data: #{data}>"
    end
  end

  # SNAP response object
  class SnapResult < Result

    # HTTP response status code
    def status_code
      @response.status.to_i
    end

    # DEPRECATED, please use #token instead
    def token_id
      if defined?(ActiveSupport::Deprecation)
        ActiveSupport::Deprecation.warn("`token_id` on SnapResult is deprecated.  Please use `token` instead.")
      else
        warn "DEPRECATION WARNING: `token_id` on SnapResult is deprecated.  Please use `token` instead."
      end
      @data[:token]
    end

    # Acccessor for <tt>token</tt> value
    def token
      @data[:token]
    end

    # Acccessor for <tt>redirect_url</tt> value
    def redirect_url
      @data[:redirect_url]
    end

    def success?
      status_code == 201
    end
  end
end
