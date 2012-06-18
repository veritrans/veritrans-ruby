require 'faraday'
require "addressable/uri"

module VT
  module MerchantPostData
    PKEYS = [
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
  end

  class Test
  
    def initialize

      @params = {}
      MerchantPostData::PKEYS.each do |key|
        @params[key.to_sym] = "";    
      end

      init_merchant_info
      init_checkout_info
      init_return_url
      init_card_info
      init_shipping
      init_repeat_line1
    end

    def get_keys
      # Faraday.post 'http://127.0.0.1:4567/hi', @params
      # @resp = Faraday.post('http://192.168.10.250:80/web1/commodityRegist.action', @params)
      conn = Faraday.new(:url => 'http://192.168.10.250:80')
      @resp = conn.post do |req|
        req.url('/web1/commodityRegist.action')
        uri = Addressable::URI.new
        uri.query_values = @params
        req.body = uri.query
        # req.body = 'SETTLEMENT_TYPE=01&MERCHANT_ID=sample1&ORDER_ID=CdgkF&SESSION_ID=11cd3c131883a6c74080beb8124b288e&GROSS_AMOUNT=10&PREVIOUS_CUSTOMER_FLAG=1&CUSTOMER_STATUS=&MERCHANTHASH=7d7aaf6705375999a561d97ae5de5ccdd210013ae8301ca2882448878fa399f645f3e5d378044790c28fde23c019cf4b56f42dfb63fd437fa85dc76ff50c3184&SHIPPING_INPUT_FLAG=1&SHIPPING_SPECIFICATION_FLAG=1&SHIPPING_ADDRESS1=oke&SHIPPING_ADDRESS2=Minatoku&SHIPPING_CITY=Tokyo&SHIPPING_COUNTRY_CODE=JPN&SHIPPING_POSTAL_CODE=1606028&SHIPPING_PHONE=03111122229&CARD_NO=4111111111111111&CARD_EXP_DATE=11/14&FINISH_PAYMENT_RETURN_URL=http://192.168.10.228&UNFINISH_PAYMENT_RETURN_URL=http://192.168.10.228&ERROR_PAYMENT_RETURN_URL=http://192.168.10.228&LANG_ENABLE_FLAG=&LANG=&REPEAT_LINE=1&COMMODITY_ID=IDxx12&COMMODITY_UNIT=10&COMMODITY_NUM=1&COMMODITY_NAME1=Waterbostle&COMMODITY_NAME2=Waterbotstle+in+Indonen1'
      end
      parse_body(@resp.body)
    end
  
    private
  
    def parse_body(body)
      arrs = body.split("\r\n")
      Hash[arrs[-2,2].collect{|x|x.split("=")}]
    end
  
    #"{\"SETTLEMENT_TYPE\"=>\"01\", \"MERCHANT_ID\"=>\"sample1\", \"ORDER_ID\"=>\"4534\", \"SESSION_ID\"=>\"234234\", \"GROSS_AMOUNT\"=>\"10\", \"PREVIOUS_CUSTOMER_FLAG\"=>\"\", \"CUSTOMER_STATUS\"=>\"1\", \"MERCHANTHASH\"=>\"ae1cb62605200a0bdc59659404f8c2122cc5b7a0dc440c5003966bb2a2db2df294d5241d367e08bdc63d5a8be44219ccc3d3746fac4fcaffdb14b093342a13d4\", \"EMAIL\"=>\"test@veritrans.co.jp\", \"FIRST_NAME\"=>\"SMITH\", \"LAST_NAME\"=>\"JOHN\", \"POSTAL_CODE\"=>\"GU24OBLs\", \"ADDRESS1\"=>\"52 The Street\", \"ADDRESS2\"=>\"Village Town\", \"CITY\"=>\"London\", \"COUNTRY_CODE\"=>\"GBR\", \"PHONE\"=>\"0123456789123\", \"SHIPPING_INPUT_FLAG\"=>\"1\", \"SHIPPING_SPECIFICATION_FLAG\"=>\"1\", \"SHIPPING_FIRST_NAME\"=>\"TARO\", \"SHIPPING_LAST_NAME\"=>\"YAMADA\", \"SHIPPING_ADDRESS1\"=>\"Roppongi1-6-1\", \"SHIPPING_ADDRESS2\"=>\"Minatoku\", \"SHIPPING_CITY\"=>\"Tokyo\", \"SHIPPING_COUNTRY_CODE\"=>\"JPN\", \"SHIPPING_POSTAL_CODE\"=>\"1606028\", \"SHIPPING_PHONE\"=>\"03111122229\", \"CARD_NO\"=>\"4111111111111111\", \"CARD_EXP_DATE\"=>\"11/14\", \"FINISH_PAYMENT_RETURN_URL\"=>\"http://192.168.10.228\", \"UNFINISH_PAYMENT_RETURN_URL\"=>\"http://192.168.10.228\", \"ERROR_PAYMENT_RETURN_URL\"=>\"http://192.168.10.228\", \"LANG_ENABLE_FLAG\"=>\"\", \"LANG\"=>\"\", \"REPEAT_LINE\"=>\"1\", \"COMMODITY_ID\"=>\"IDxx1\", \"COMMODITY_UNIT\"=>\"10\", \"COMMODITY_NUM\"=>\"1\", \"COMMODITY_NAME1\"=>\"Waterbotle\", \"COMMODITY_NAME2\"=>\"Waterbottle in Indonesian\"}"

    def init_merchant_info
      @params[:MERCHANTHASH]    = "ae1cb62605200a0bdc59659404f8c2122cc5b7a0dc440c5003966bb2a2db2df294d5241d367e08bdc63d5a8be44219ccc3d3746fac4fcaffdb14b093342a13d4"
      @params[:SETTLEMENT_TYPE] = "01"
      @params[:MERCHANT_ID]     = "sample1"
      @params[:ORDER_ID]        = "4534"
      @params[:SESSION_ID]      = "4534"
    end
  
    def init_checkout_info
      @params[:CUSTOMER_STATUS] = "1"
      @params[:EMAIL]           = "test@veritrans.co.jp"
      @params[:FIRST_NAME]      = "SMITH"
      @params[:LAST_NAME]       = "JOHN"
      @params[:POSTAL_CODE]     = "GU24OBLs"
      @params[:ADDRESS1]        = "52 The Street"
      @params[:ADDRESS2]        = "Village Town"
      @params[:CITY]            = "London"
      @params[:COUNTRY_CODE]    = "GBR"
      @params[:PHONE]           = "0123456789123"
    end
  
    def init_repeat_line1
      @params[:GROSS_AMOUNT]    = "10"
      @params[:REPEAT_LINE]     = "1"
      @params[:COMMODITY_ID]    = "IDxx1"
      @params[:COMMODITY_UNIT]  = "10"
      @params[:COMMODITY_NUM]   = "1"
      @params[:COMMODITY_NAME1] = "Waterbotle"
      @params[:COMMODITY_NAME2] = "Waterbottle in Indonesian"
    end
    
    def init_repeat_line2
      @params[:GROSS_AMOUNT]    = "20"
      @params[:REPEAT_LINE]     = "2"
      
      @params[:COMMODITY_ID1]    = "IDxx1"
      @params[:COMMODITY_UNIT1]  = "10"
      @params[:COMMODITY_NUM1]   = "1"
      @params[:COMMODITY_NAME11] = "Waterbotle"
      @params[:COMMODITY_NAME21] = "Waterbottle in Indonesian"
      
      @params[:COMMODITY_ID2]    = "IDxx1"
      @params[:COMMODITY_UNIT2]  = "10"
      @params[:COMMODITY_NUM2]   = "1"
      @params[:COMMODITY_NAME12] = "Cookies"
      @params[:COMMODITY_NAME22] = "Cookies in Indonesian"
    end
  
    def init_return_url
      @params[:FINISH_PAYMENT_RETURN_URL]   = "http://192.168.10.228"
      @params[:UNFINISH_PAYMENT_RETURN_URL] = "http://192.168.10.228"
      @params[:ERROR_PAYMENT_RETURN_URL]    = "http://192.168.10.228"
    end
  
    def init_card_info
      @params[:CARD_NO]                     = "4111111111111111"
      @params[:CARD_EXP_DATE]               = "11/14"
    end
  
    def init_shipping
      @params[:SHIPPING_INPUT_FLAG]         = "1"
      @params[:SHIPPING_SPECIFICATION_FLAG] = "1"
      @params[:SHIPPING_FIRST_NAME]         = "TARO"
      @params[:SHIPPING_LAST_NAME]          = "YAMADA"
      @params[:SHIPPING_POSTAL_CODE]        = "1606028"
      @params[:SHIPPING_PHONE]              = "03111122229"
    end

  end
end

#➜  poppy  irb
#1.9.3-p194 :001 > require './my_test'
# => true 
#1.9.3-p194 :002 > VT::Test.new.get_keys
# => {"MERCHANT_ENCRYPTION_KEY"=>"K6499", "BROWSER_ENCRYPTION_KEY"=>"K7600"} 
#1.9.3-p194 :003 > x['ERROR_MESSAGE']

#"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n\r\n\r\n\r\nMERCHANT_ENCRYPTION_KEY=K8331\r\nBROWSER_ENCRYPTION_KEY=K4456\r\n"
#"\r\n\r\n\r\nERROR_MESSAGE=REPEAT_LINE and product information are not corresponding.\r\n"

