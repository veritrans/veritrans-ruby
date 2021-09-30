require 'veritrans'
require 'json'
require 'sinatra'

Veritrans.setup do
  config.load_yml File.dirname(__FILE__) + "/veritrans.yml#development"
end

# Alternative way to to initialize core api client:
# mt_client = Midtrans.new(
#   server_key: "your server key",
#   client_key: "your client key",
#   api_host: "https://api.sandbox.midtrans.com", # default
#   http_options: {}, # optional
#   logger: Logger.new(STDOUT), # optional
#   file_logger: Logger.new(STDOUT), # optional
# )

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
  result = Veritrans.create_widget_token(
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
  result = Veritrans.create_widget_token(
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
  @result = Veritrans.charge(
    payment_type: "credit_card",
    credit_card: {
      token_id: params[:token_id],
      authentication: params[:secure]
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




