# Description

# Reference

# Example Usage

Sample command line in irb
~~~~~~~~~~~~~~~~~~~~~~~~~~
>bundle
>irb

require './lib/veritrans'
client = Veritrans::Client.new
client.order_id   = "1234"
client.session_id = "3456"
client.gross_amount = "10"
client.commodity    = [
  {"COMMODITY_ID" => "IDxx1", "COMMODITY_UNIT" => "10", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "Waterbotle", "COMMODITY_NAME2" => "Waterbottle in Indonesian"}
]
client.get_keys

OR

client = Veritrans::Client.new do 
  @order_id   = "1234"
  @session_id = "3456"
  @gross_amount = "10"
  @commodity    = [
    {"COMMODITY_ID" => "IDxx1", "COMMODITY_UNIT" => "10", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "Waterbotle", "COMMODITY_NAME2" => "Waterbottle in Indonesian"}
  ]
end

# Install

     $ gem install veritrans