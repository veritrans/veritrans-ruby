class VeritransController < ApplicationController

  # post action after user submit checkout-form 
  # Ex POST:
  # {"gross_amount" => "7000000",
  #  "commodity"=>[
  #    {
  #    "COMMODITY_ID"    => "Espirit", 
  #    "COMMODITY_QTY"   => "4",
  #    "COMMODITY_PRICE" => "500000",
  #    "COMMODITY_NAME1" => "Espirit"
  #    },
  #    {
  #    "COMMODITY_ID"    => "Tablet", 
  #    "COMMODITY_QTY"   => "2",
  #    "COMMODITY_PRICE" => "2500000",
  #    "COMMODITY_NAME1" => "Tablet"
  #    }]}
  # Return from get_keys: 
  # TOKEN_MERCHANT = dYWRjRr2ZbJEqMQaqDLIaWeoLl1Tuk3g7g3T1gKGrE5ibYJoZ4
  # TOKEN_BROWSER  = lh4TxpAyB2NhrKTlqGbW1LRPoA6RgyI6roJ2EIII6J29j7gYoP
  def confirm
    puts params.inspect
    client = ::Veritrans::Client.new
    client.order_id     =   "dummy#{(0...12).map{65.+(rand(25))}.join}"
    client.session_id   = "session#{(0...12).map{65.+(rand(25))}.join}"
    client.gross_amount = params["gross_amount"]
    client.commodity    = params["commodity"]

    client.billing_address_different_with_shipping_address = "1" #'1':Different Address with shipping
    client.required_shipping_address = "1"                       #'0':Not required shipping address

    client.shipping_first_name   = "Sam"
    client.shipping_last_name    = "Anthony"
    client.shipping_address1     = "Buaran I" 
    client.shipping_address2     = "Pulogadung"
    client.shipping_city         = "Jakarta"
    client.shipping_country_code = "IDN"
    client.shipping_postal_code  = "16954"
    client.shipping_phone        = "0123456789123"

    client.email    = "sam.anthony@gmail.com" # pay-notification email
  # client.promo_id = "PROMO_MERCHANT_NAME" #if there is a join-promo w/ CC issuer

    client.get_keys
    @client = client

    puts client.inspect
    # puts params.inspect

    render :layout => 'layout_auto_post'
  end

  # post-redirection from Veritrans to Merchants Web
  # Ex: {"orderId"  =>"dummy877684698685878869896765",
  #      "sessionId"=>"session837985748788668181718189"}
  def cancel
    # logic after user cancel the transaction

    puts "cccccccccccccc"
    puts params.inspect

    render :text => "CANCEL_PAY"
  end

  # Server to Server post-notification(action) from Veritrans to Merchants Server 
  # Ex: {"mErrMsg"=>"",
  #      "mStatus"=>"success",
  #      "TOKEN_MERCHANT"=>"dYWRjRr2ZbJEqMQaqDLIaWeoLl1Tuk3g7g3T1gKGrE5ibYJoZ4",
  #      "vResultCode"=>"C001000000000000",
  #      "orderId"=>"dummy877684698685878869896765"}
  def pay
    # logic to check:
    # 1.validate request
    # 2.update db if valid 

    puts "vvvvvvvvvvvvvv"
    puts params.inspect

    render :text => "OK"  
  end

  # post-redirection from Veritrans to Merchants Web
  # Ex: {"orderId"=>"dummy877684698685878869896765",
  #      "mStatus"=>"success",
  #      "vResultCode"=>"C001000000000000",
  #      "sessionId"=>"session837985748788668181718189"}
  def finish
    # logic after success transaction occured

    puts "ffffffffffffff"
    puts params.inspect

    render :text => "FINISH"
  end

  # need scenario that could be try
  # post-redirection from Veritrans to Merchants Web
  # Ex: {"orderId"=>"dummy877684698685878869896765",
  #      "mStatus"=>"failure",
  #      "vResultCode"=>"NH13000000000000",
  #      "sessionId"=>"session837985748788668181718189"}
  def error
    # logic after error transaction occured

    puts "eeeeeeeeeeeeee"
    puts params.inspect

    render :text => "ERROR"
  end

end
