$:.push(File.expand_path("../../lib", __FILE__))

require 'json'

require 'veritrans'
require 'sinatra'

Veritrans.setup do
  config.load_yml "./veritrans.yml#development"

  # config.server_key = "..."
  # config.client_key = "..."
  # config.api_host = "https://api.sandbox.veritrans.co.id" (default)
end

# Veritrans.config.server_key
# Veritrans.config.client_key
# Veritrans.config.api_host

set :public_folder, "."
set :views,         "."

def generate_order_id
  "testing-#{rand.round(4)}-#{Time.now.to_i}"
end

get "/" do
  erb :index
end

post "/charge_vtdirect" do
  @result = Veritrans.charge(
    payment_type: "credit_card",
    credit_card: { token_id: params[:token_id] },
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: params[:gross_amount]
    }
  )

  erb :response
end

get "/charge_vtweb" do
  @result = Veritrans.charge(
    payment_type: "VTWEB",
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: params[:gross_amount]
    }
  )

  erb :response
end

post "/webhook" do
  post_body = request.body.read
  request_data = JSON.parse(post_body)

  #puts "Recieved #{post_body.size} bytes"
  #puts post_body

  verified_data = Veritrans.status(request_data['transaction_id'])

  if verified_data.status_code != 404
    puts "--- Transaction callback ---"
    puts "Payment:        #{verified_data.data[:order_id]}"
    puts "Payment type:   #{verified_data.data[:payment_type]}"
    puts "Payment status: #{verified_data.data[:transaction_status]}"
    puts "Fraud status:   #{verified_data.data[:fraud_status]}" if verified_data.data[:fraud_status]
    puts "Payment amount: #{verified_data.data[:gross_amount]}"
    puts "--- Transaction callback ---"
  end

  return "ok"
end