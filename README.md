# Veritrans Weblink Type Ruby integration library

Ruby Wrapper prepare-data for submiting to veritrans server and get token for further process

## How to use 

**Installation**

     $ gem install veritrans

Given you already have cart ready for checkout

** create a veritrans instance & order information**

    require 'veritrans'
    client = Veritrans::Client.new
    client.order_id     = "your_unique_order_id"
    client.session_id   = "your_application_session_id"

** set the commodity & gross amount**

    client.commodity    = [
      {"COMMODITY_ID"    => "ID001",
       "COMMODITY_UNIT"  => "10",
       "COMMODITY_NUM"   => "1", 
       "COMMODITY_NAME1" => "Waterbotle", 
       "COMMODITY_NAME2" => "Waterbottle in Indonesian"
      }
    ]
    client.gross_amount = "10"

**set the shipping address**

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


**set email notification**

    client.email = "sam.anthony@gmail.com"

**request for a key**

    client.get_keys

for complete demo you can check-out sample-code on veritrans-ruby-sample-cart


## Sample Rails-app

This gem can provide a sample checkout in new rails app.

**create new rails app**

    rails new sample-cart

**add "veritrans" gem to Gemfile**

    gem 'veritrans', '1.2.0'

**bundle update**
    
    bundle 

**create sample checkout**

    rails g veritrans:sample

**update file 'config/veritrans.yml'**

    development:
       merchant_id: "your_merchant_id"
       merchant_hash_key: "your_merchant_hash_key"

**now you can test yout rails app**

    rails s


