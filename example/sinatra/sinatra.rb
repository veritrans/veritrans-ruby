require 'bundler/setup'

require 'veritrans'
require 'json'
require 'sinatra'

Veritrans.setup do
  config.load_yml File.dirname(__FILE__) + "/veritrans.yml#development"
end

  set :public_folder, File.dirname(__FILE__)
  set :views, File.dirname(__FILE__)
  set :run, $0 == __FILE__

  def generate_order_id
    "sinatra-order-#{rand(1..10000)}"
  end

  get "/" do
    erb :index
  end

  get "/snap" do
    result = Veritrans.create_widget_token(
      transaction_details: {
        order_id: generate_order_id,
        gross_amount: 100000
      }
    )
    @token = result.token
    erb :snap
  end

  get "/snapredirect" do
    result = Veritrans.create_widget_token(
      transaction_details: {
        order_id: generate_order_id,
        gross_amount: 100000
      }
    )
    @redirecturl = result.redirect_url
    erb :snapredirect
  end

post"/coreapi" do
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




