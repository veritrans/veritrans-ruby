module Veritrans
  module DemoData
    def init_order_info
      @order_id        = "1234"  #{}"#{(0...4).map{65.+(rand(25))}.join}"
      @session_id      = "3456"  #{}"#{(0...4).map{65.+(rand(25))}.join}"
    end

    def ini_commodity
      @gross_amount = "10"
      @commodity    = [
        {"COMMODITY_ID" => "IDxx1", "COMMODITY_UNIT" => "10", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "Waterbotle", "COMMODITY_NAME2" => "Waterbottle in Indonesian"}
      ]
    end
  
    def init_checkout_info
      @customer_status = "1"
      @email           = "test@veritrans.co.jp"
      @first_name      = "SMITH"
      @last_name       = "JOHN"
      @postal_code     = "GU24OBLs"
      @address1        = "52 The Street"
      @address2        = "Village Town"
      @city            = "London"
      @country_code    = "GBR"
      @phone           = "0123456789123"
    end
  
    def init_card_info
      @card_no       = "4111111111111111"
      @card_exp_date = "11/14"
    end
  
    def init_shipping

      @shipping_input_flag         = "1"
      @shipping_specification_flag = "1"
      @shipping_first_name         = "TARO"
      @shipping_last_name          = "YAMADA" 
      @shipping_postal_code        = "1606028"
      @shipping_phone              = "03111122229"
    end
  end
end
