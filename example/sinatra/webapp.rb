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

get "/snapredirect" do
  result = Midtrans.create_snap_redirect_url(
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: 100000,
      secure: true
    }
  )
  @redirecturl = result.redirect_url
  erb :snapredirect
end

post "/coreapi-card-charge-ajax-handler" do
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




