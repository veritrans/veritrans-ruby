require "yaml"

# :nodoc:
module Veritrans

  # hold constants configuration define in server merchant
  module Config

    # server Veritrans - defined in gem - no change!
    SERVER_HOST          = 'https://payments.veritrans.co.id' #'http://192.168.10.250:80'

    # Request Key Url - use in #get_keys - defined in gem - no change!
    REQUEST_KEY_URL      = "/web1/commodityRegist.action"

    # Payment Redirect Url - defined in gem - no change!
    PAYMENT_REDIRECT_URL = "/web1/deviceCheck.action"
    
    # :nodoc:
    CUSTOMER_SPECIFICATION_FLAG = '0' #Billing same as shipping address '1' Different, manually input in Veritrans-web

    # Default Settlement method:
    SETTLEMENT_TYPE_CARD = "01" #Paymanet Type
    
    # Flag: Sales and Sales Credit, 0: only 1 credit. If not specified, 0
    CARD_CAPTURE_FLAG = "1"

    def Config.included(mod)
      class <<self
        @@config_env = ::Object.const_defined?(:Rails) ? Rails.env : "development"
        @@config = YAML.load_file("./config/veritrans.yml")
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
