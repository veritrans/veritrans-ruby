$:.push(File.expand_path("../../lib", __FILE__))

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
      gross_amount: 30_000
    }
  )

  erb :response
end