# Addressable

# Description

# Reference

# Example Usage

Sample command line in irb
~~~~~~~~~~~~~~~~~~~~~~~~~~
>bundle
>irb

require './lib/veritrans'
x = Veritrans::Client.new
x.order_id   = "1234"
x.session_id = "3456"
x.gross_amount = "10"
x.commodity    = [
  {"COMMODITY_ID" => "IDxx1", "COMMODITY_UNIT" => "10", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "Waterbotle", "COMMODITY_NAME2" => "Waterbottle in Indonesian"}
]
x.get_keys

OR

x = Veritrans::Client.new do 
  @order_id   = "1234"
  @session_id = "3456"
  @gross_amount = "10"
  @commodity    = [
    {"COMMODITY_ID" => "IDxx1", "COMMODITY_UNIT" => "10", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "Waterbotle", "COMMODITY_NAME2" => "Waterbottle in Indonesian"}
  ]
end

# Install

     $ gem install veritrans