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
      parms = prepare_params(@@attr).to_json
      basic = Base64.encode64("#{server_key}:")
      copt  = {:url => server_host}
      copt[:ssl] = { :ca_path => VTDirect.config["ca_path"] } if VTDirect.config["ca_path"] #"/usr/lib/ssl/certs"
      conn  = Faraday.new( copt )
      @resp = conn.post do |req|
        req.url(charges_url)
        req.headers['Content-Type']  = 'application/json'
        req.headers['Authorization'] = "Basic #{basic}"
        req.body = parms
      end.env
      puts ">>>>#{parms}<<<<"
      puts ">>>>#{conn}<<<<"
      puts ">>>>#{@resp}<<<<"
      @data = @resp[:body]
    end

    # :nodoc:
    # def ca_path
    #   return VTDirect.config["ca_path"] ? VTDirect.config["ca_path"] : Config::CA_PATH
    # end

    # :nodoc:
    def server_host
      return VTDirect.config["server_host"] ? VTDirect.config["server_host"] : Config::SERVER_HOST
    end

    # :nodoc:
    def tokens_url
      return Client.config["tokens_url"] ? Client.config["tokens_url"] : Config::TOKENS_URL
    end

    # :nodoc:
    def charges_url
      return Client.config["charges_url"] ? Client.config["charges_url"] : Config::CHARGES_URL
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
        params[key.to_s.downcase] = value if value 
      end
      return params
    end
  end
end
