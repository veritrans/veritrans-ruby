require 'faraday'

class MyTest
  
  def initialize
    pkeys = [
      "SETTLEMENT_TYPE", 
      "MERCHANT_ID", 
      "ORDER_ID", 
      "SESSION_ID", 
      "GROSS_AMOUNT", 
      "PREVIOUS_CUSTOMER_FLAG", 
      "CUSTOMER_STATUS", 
      "MERCHANTHASH", 
      "EMAIL", 
      "FIRST_NAME", 
      "LAST_NAME", 
      "POSTAL_CODE", 
      "ADDRESS1", 
      "ADDRESS2", 
      "CITY", 
      "COUNTRY_CODE", 
      "PHONE", 
      "SHIPPING_INPUT_FLAG", 
      "SHIPPING_SPECIFICATION_FLAG", 
      "SHIPPING_FIRST_NAME", 
      "SHIPPING_LAST_NAME", 
      "SHIPPING_ADDRESS1", 
      "SHIPPING_ADDRESS2", 
      "SHIPPING_CITY", 
      "SHIPPING_COUNTRY_CODE", 
      "SHIPPING_POSTAL_CODE", 
      "SHIPPING_PHONE", 
      "CARD_NO", 
      "CARD_EXP_DATE", 
      "FINISH_PAYMENT_RETURN_URL", 
      "UNFINISH_PAYMENT_RETURN_URL", 
      "ERROR_PAYMENT_RETURN_URL", 
      "LANG_ENABLE_FLAG", 
      "LANG", 
      "REPEAT_LINE", 
      "COMMODITY_ID", 
      "COMMODITY_UNIT", 
      "COMMODITY_NUM", 
      "COMMODITY_NAME1", 
      "COMMODITY_NAME2"
      ]

      @params = {}
      pkeys.each do |key|
        @params[key.to_sym] = '-';    
      end
    end
    
    def get_keys
      Faraday.post 'http://127.0.0.1:4567/hi', params
    end
  end