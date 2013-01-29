# VT-Link Type Ruby integration library

## Installation

     $ gem install veritrans

## How to use (Rails)

###Add veritrans to Gemfile
    gem 'veritrans'

    bundle install

###Generate veritrans.yml
    rails g veritrans:install

###Edit merchant info in config/veritrans.yml file
    development:
      merchant_id: "test_id"
      merchant_hash_key: "abcdefghijklmnopqrstuvwxyz"
      finish_payment_return_url: "http://localhost/finish"
      unfinish_payment_return_url: "http://localhost/cancel"
      server_host: "http://veritrans.dev"
      charges_url: "/charges"
      token_url:   "/tokens"

##STEP 1 : Requesting key
Given you already have cart ready for checkout.
We create a veritrans instance

    @client = Veritrans::Client.new
    @client.order_id                 = "your_unique_order_id"
    @client.session_id               = "your_application_session_id"
    @client.billing_address_different_with_shipping_address = 1
    @client.required_shipping_address = 0    
    
    
dont forget to set your commodity

    client.commodity    = [
      {"COMMODITY_ID"    => "sku1",
       "COMMODITY_PRICE"  => "10000",
       "COMMODITY_QTY"   => "1", 
       "COMMODITY_NAME1" => "Kaos", 
       "COMMODITY_NAME2" => "T-Shirt"
      },
      {"COMMODITY_ID"    => "sku1",
       "COMMODITY_PRICE"  => "20000",
       "COMMODITY_QTY"   => "1", 
       "COMMODITY_NAME1" => "Kaos", 
       "COMMODITY_NAME2" => "Pants"
      }
    ]
    client.gross_amount = "30000"

request for a key

    # get keys from Veritrans
    @client.get_keys

     # save the merchant token
     if @client.token["ERROR_MESSAGE"]
        # error accoured
     else        
       @order.token_merchant = @client.token["TOKEN_MERCHANT"]
       @order.save   
     end
       

##STEP 2 : Redirect user to Veritrans payment page

Prepare the FORM to redirect the customer 
    
    <%= form_tag(@client.redirect_url, :name => "form_auto_post") do -%>
      <input type="hidden" name="MERCHANT_ID" value="<%= @client.merchant_id %>"> 
      <input type="hidden" name="ORDER_ID" value="<%= @client.order_id %>">
      <input type="hidden" name="TOKEN_BROWSER" value="<%= @client.token["TOKEN_BROWSER"] %>">
      <div align="center">
      <input type="submit" value="submit">
      </div>
    <% end %>

##STEP 3 : Responding Veritrans Payment Notification
After the payment is completed Veritrans will contact Merchant's web server.
As a Merchant, you need to response this query. Validate request from veritrans, make sure it comes from veritrans not from hacker

     # Assume that we wave Order model to keep our order data
     @order = Order.find(param["orderId"])

     # Server to Server post-notification(action) from Veritrans to Merchants Server 
     # Ex: {"mErrMsg"=>"",
     #      "mStatus"=>"success",
     #       "TOKEN_MERCHANT"=>"dYWRjRr2ZbJEqMQaqDLIaWeoLl1Tuk3g7g3T1gKGrE5ibYJoZ4",
     #      "vResultCode"=>"C001000000000000",
     #      "orderId"=>"dummy877684698685878869896765"}
        
     #Verify that token merchant is exactly the same with what comes from veritrans
      if @order.token_merchant == params["TOKEN_MERCHANT"]
        @order.paid!
      else
         # you can log for invalid notification
      end         

