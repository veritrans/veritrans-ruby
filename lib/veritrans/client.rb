module Veritrans
  class Client

    def initialize(&block)
      class <<self
        self
      end.class_eval do
        attr_accessor(:commodity, *PostData::Params) 
      end
      if block_given?
        self.instance_eval(&block)
        self.get_keys
      end
    end

    def get_keys
      init_instance

      params = prepare_params(PostData::HiddenParams, PostData::Params)

      if @commodity.class == Array
        commodity = @commodity.collect do |data|
          uri = Addressable::URI.new
          uri.query_values = data
          uri.query        
        end
      end

      uri = Addressable::URI.new
      uri.query_values = params
      query_string = "#{uri.query}&REPEAT_LINE=#{@commodity.length}&#{commodity.join('&')}"
      #puts query_string

      conn = Faraday.new(:url => Config::SERVER_HOST)
      @resp = conn.post do |req|
        req.url(Config::REQUEST_KEY_URL)
        req.body = query_string
      end.env
      puts @resp
      @resp.delete(:ssl)
      @resp.delete(:request)
      @resp.delete(:response)
      @resp.delete(:request_headers)
      @resp.delete(:parallel_manager)
      @resp[:url] = @resp[:url].to_s

      @token = parse_body(@resp[:body])
    end

    def merchant_id
      Config::MERCHANT_ID
    end

    def token
      @token
    end

    private

    def merchanthash
      # Generate merchant hash code
      HashGenerator::generate(merchant_id, settlement_type, order_id, gross_amount);
    end

    def settlement_type
      Config::SETTLEMENT_TYPE_CARD
    end

    def parse_body(body)
      arrs = body.split("\r\n")
      Hash[arrs[-2,2].collect{|x|x.split("=")}]
    end
  
    def init_instance
      @token                       = nil
      # @settlement_type           = Config::SETTLEMENT_TYPE_CARD
      @finish_payment_return_url   = Config::FINISH_PAYMENT_RETURN_URL
      @unfinish_payment_return_url = Config::UNFINISH_PAYMENT_RETURN_URL
      @error_payment_return_url    = Config::ERROR_PAYMENT_RETURN_URL
    end

    def prepare_params(*arg)
      params = {}
      arg.flatten.each do |key|
        value = self.send(key)
        params[key.upcase] = value if value 
      end
      return params
    end

  end
end
