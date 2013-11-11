require "yaml"

# :nodoc:
module Veritrans

  # hold constants configuration define in server merchant
  module Config

    # server Veritrans - defined in gem - no change!
    SERVER_HOST = "https://vtweb.veritrans.co.id"

    # Request Key Url - use in #get_keys - defined in gem - no change!
    REQUEST_KEY_URL      = "/web1/commodityRegist.action"

    # Request Key Url - use in #get_keys - defined in gem - no change!
    TOKENS_URL            = "/vtdirect/v1/tokens"

    # Charges Url - use in #get_keys - defined in gem - no change!
    CHARGES_URL          = "/vtdirect/v1/charges"

    # Void Url - use in #get_keys - defined in gem - no change!
    VOID_URL             = "/vtdirect/v1/void"

    # Payment Redirect Url - defined in gem - no change!
    PAYMENT_REDIRECT_URL = "/web1/deviceCheck.action"

    # CA_PATH
    # CA_PATH = "/usr/lib/ssl/certs"
    
    # :nodoc:
    CUSTOMER_SPECIFICATION_FLAG = '0' #Billing same as shipping address '1' Different, manually input in Veritrans-web

    # Default Settlement method:
    SETTLEMENT_TYPE_CARD = "01" #Paymanet Type
    
    # Flag: Sales and Sales Credit, 0: only 1 credit. If not specified, 0
    CARD_CAPTURE_FLAG = "1"

    def Config.included(mod)
      class <<self
        template = {
          'merchant_id' => nil,
          'merchant_hash_key' => nil,
          'finish_payment_return_url' => nil,
          'unfinish_payment_return_url' => nil,
          'error_payment_return_url' => nil,
          'server_key' => nil,
          'server_host' => nil,
          'charges_url' => nil,
          'token_url' => nil
        }
        @@config_env = ::Object.const_defined?(:Rails) ? Rails.env : "development"
        @@config = File.exists?("./config/veritrans.yml") ? YAML.load_file("./config/veritrans.yml") : {}
        @@config['development'] = {} if !@@config['development']
        @@config['production' ] = {} if !@@config['production']
        @@config['development'] = template.clone.merge(@@config['development'])
        @@config['production']  = template.clone.merge(@@config['production'])
        #@@config['production' ].merge!(template)
      end

      mod.instance_eval <<CODE

      def self.config_env=(env)
        @@config_env = env
      end

      def self.config
        @@config[@@config_env]
      end 
CODE

    end
  end
end
