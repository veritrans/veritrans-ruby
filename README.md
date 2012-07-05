# Description

Ruby Wrapper for preparinng data to submit to veritrans server and get token for further process

# Reference


# Example Usage

    require 'veritrans'
    client = Veritrans::Client.new
    client.order_id     = "dummy#{(0...12).map{65.+(rand(25))}.join}"
    client.session_id   = "session#{(0...12).map{65.+(rand(25))}.join}"
    client.gross_amount = "10"
    client.commodity    = [
      {"COMMODITY_ID"    => "IDxx1",
       "COMMODITY_UNIT"  => "10",
       "COMMODITY_NUM"   => "1", 
       "COMMODITY_NAME1" => "Waterbotle", 
       "COMMODITY_NAME2" => "Waterbottle in Indonesian"
      }
    ]
    client.shipping_flag         = "1"
    client.shipping_first_name   = "Sam"
    client.shipping_last_name    = "Anthony"
    client.shipping_address1     = "Buaran I" 
    client.shipping_address2     = "Pulogadung"
    client.shipping_city         = "Jakarta"
    client.shipping_country_code = "IDN"
    client.shipping_postal_code  = "16954"
    client.shipping_phone        = "0123456789123"
    client..shipping_method      = "N"
    client.get_keys

# Install

     $ gem install veritrans








