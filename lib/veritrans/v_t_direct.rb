require 'base64'
require 'json'
# :nodoc:
module Veritrans

  # :nodoc:
  class VTDirect
    include Config
    @@attr = [:token_id, :order_id, :order_items, :gross_amount, :email, :shipping_address, :billing_address]

    # constructor to create instance of Veritrans::Client
    def initialize
      class <<self
        self
      end.class_eval do
        attr_accessor *@@attr
      end
    end

    # Example:
    #
    #   vt_direct = Veritrans::VTDirect.new
    #   vt_direct.token_id    = "32eeeb9f-8ac3-b824-eb6d-faaa25240d27"
    #   vt_direct.order_id    = "order_5"
    #   vt_direct.order_items = [
    #           {
    #              id: "10",
    #              price: 100,
    #              qty: 1,
    #              name1: "Mie",
    #              name2: "Goreng"
    #           },
    #           {
    #              id: "11",
    #              price: 100,
    #              qty: 1,
    #              name1: "Mie",
    #              name2: "Kuah"
    #           }
    #        ]
    #   vt_direct.gross_amount = 200
    #   vt_direct.email     = "echo.khannedy@gmail.com"
    #   vt_direct.shipping_address = {
    #          first_name: "Sam",
    #          last_name: "Anthony",
    #          address1: "Buaran I",
    #          address2: "Pulogadung",
    #          city: "Jakarta",
    #          country_code: "IDN",
    #          postal_code: "16954",
    #          phone: "0123456789123"           
    #        }
    #   vt_direct.billing_address = {
    #          first_name: "Sam",
    #          last_name: "Anthony",
    #          address1: "Buaran I",
    #          address2: "Pulogadung",
    #          city: "Jakarta",
    #          country_code: "IDN",
    #          postal_code: "16954",
    #          phone: "0123456789123"           
    #        }
    #   vt_direct.charges
    #
    def charges
      # conn = Faraday.new(:url => 'http://veritrans.dev/charges')
      parms = prepare_params([:server_key]+@@attr).to_json
      basic = Base64.encode64("#{server_key}:")
      conn  = Faraday.new(:url => server_host)
      @resp = conn.post do |req|
        req.url('/charges')
        req.headers['Content-Type']  = 'application/json'
        req.headers['Authorization'] = "Basic #{basic}"
        req.body = parms
      end.env
      @data = @resp[:body]
    end

    # :nodoc:
    def server_host
      return VTDirect.config["server_host"] ? VTDirect.config["server_host"] : Config::SERVER_HOST
    end

    # :nodoc:
    def server_key
      return VTDirect.config["server_key"]
    end

    # :nodoc:
    def server_key= new_server_key
      VTDirect.config["server_key"] = new_server_key
    end

    private

    def prepare_params(*arg)
      params = {}
      arg.flatten.each do |key|
        value = self.send(key)
        params[key.downcase] = value if value 
      end
      return params
    end
  end
end
