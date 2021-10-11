require 'veritrans'
require 'json'
require 'sinatra'

Midtrans.config.server_key = "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2"
Midtrans.config.client_key = "SB-Mid-client-ArNfhrh7st9bQKmz"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

set :public_folder, File.dirname(__FILE__)
set :views, File.dirname(__FILE__)
set :run, $0 == __FILE__

def generate_order_id
  "sinatra-example-#{Time.now.to_i}"
end

get "/" do
  erb :index
end

get "/snap" do
  result = Midtrans.create_snap_token(
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: 100000,
      secure: true
    }
  )
  @token = result.token
  erb :snap
end

get "/snap_redirect" do
  result = Midtrans.create_snap_redirect_url(
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: 100000,
      secure: true
    }
  )
  @redirecturl = result.redirect_url
  erb :snap_redirect
end

post "/coreapi_card_charge_ajax_handler" do
  @data = JSON.parse(request.body.read)
  @result = Midtrans.charge(
    payment_type: "credit_card",
    credit_card: {
      token_id: @data['token_id'],
      authentication: @data['authenticate_3ds']
    },
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: 20000
    })

  if params[:format] == "json"
    content_type :json
    @result.response.body
  else
    erb :response
  end
end

post "/check_transaction_status" do
  @data = JSON.parse(request.body.read)
  transaction_id = @data['transaction_id']
  @result = Midtrans.status(transaction_id)

  if params[:format] == "json"
    content_type :json
    @result.response.body
  else
    erb :response
  end
end

post "/handle_http_notification" do
  post_body = JSON.parse(request.body.read)
  notification = Midtrans.status(post_body['transaction_id'])

  order_id = notification.data[:order_id]
  payment_type = notification.data[:payment_type]
  transaction_status = notification.data[:transaction_status]
  fraud_status = notification.data[:fraud_status]

  puts "Transaction order_id: #{order_id}"
  puts "Payment type:   #{payment_type}"
  puts "Transaction status: #{transaction_status}"
  puts "Fraud status:   #{fraud_status}"

  return "Transaction notification received. Order ID: #{order_id}. Transaction status: #{transaction_status}. Fraud status: #{fraud_status}"

  # Sample transactionStatus handling logic
  if transaction_status == "capture" && fraud_status == "challange"
    # TODO set transaction status on your databaase to 'challenge'
  elsif transaction_status == "capture" && fraud_status == "success"
    # TODO set transaction status on your databaase to 'success'
  elsif transaction_status == "settlement"
    # TODO set transaction status on your databaase to 'success'
  elsif transaction_status == "deny"
    # TODO you can ignore 'deny', because most of the time it allows payment retries
  elsif transaction_status == "cancel" || transaction_status == "expire"
    # TODO set transaction status on your databaase to 'failure'
  elsif transaction_status == "pending"
    # Todo set transaction status on your databaase to 'pending' / waiting payment
  end

end



