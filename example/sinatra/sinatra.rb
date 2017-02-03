$:.push(File.expand_path("../../lib", __FILE__))

require 'json'

require 'veritrans'
require 'sinatra'

begin
  require 'tilt/erubis'
rescue LoadError => error
  puts "Warning: Can not load 'tilt', continue"
end

Veritrans.setup do
  config.load_yml File.dirname(__FILE__) + "/veritrans.yml#development"

  # config.server_key = "..."
  # config.client_key = "..."
  # config.api_host = "https://api.sandbox.veritrans.co.id" (default)
end

# Veritrans.config.server_key
# Veritrans.config.client_key
# Veritrans.config.api_host

set :public_folder, File.dirname(__FILE__)
set :views,         File.dirname(__FILE__)

set :run, $0 == __FILE__

def generate_order_id
  "testing-#{rand.round(4)}-#{Time.now.to_i}"
end

get "/" do
  erb :index
end

get "/recurring" do
  erb :recurring
end

get "/localization" do
  erb :localization
end

get "/points" do
  erb :points
end

get "/widget" do
  response = Veritrans.create_widget_token(
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: 30_000
    }
  )

  @token = response.token_id
  erb :widget
end

get "/widget/confirm/:transaction_id" do
  @result = Veritrans.status(params[:transaction_id])
  erb :response
end

post "/charge_vtdirect" do
  @charge_params = {
    payment_type: "credit_card",
    credit_card: {
      token_id: params[:token_id]
    },
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: params[:gross_amount].to_f,
    }
  }

  if params[:recurring] == "1"
    @charge_params[:credit_card][:recurring] = true
  end

  if params[:points_amount]
    @charge_params[:credit_card][:point_redeem_amount] = params[:points_amount]
    @charge_params[:credit_card][:bank] = "bni"
  end

  @result = Veritrans.charge(@charge_params)

  if params[:format] == "json"
    content_type :json
    @result.response.body
  else
    erb :response
  end
end

get "/charge_vtweb" do
  vtweb_options = {}

  if params[:enabled_payments] && params[:enabled_payments].size > 0
    vtweb_options[:enabled_payments] = params[:enabled_payments]
  end

  if params[:credit_card_3d_secure] && params[:credit_card_3d_secure] != ""
    vtweb_options[:credit_card_3d_secure] = params[:credit_card_3d_secure] == "true"
  end

  if params[:bin_promo] && params[:bin_promo] != ""
    vtweb_options[:credit_card_bins] = params[:bin_promo]
  end

  if params[:installment]
    vtweb_options[:payment_options] = {
      installment: {
        required: true,
        installment_terms: {}
      }
    }

    if params[:installment]['bni']
      vtweb_options[:payment_options][:installment][:installment_terms][:bni] = [3, 6, 12]
    end

    if params[:installment][:mandiri]
      vtweb_options[:payment_options][:installment][:installment_terms][:mandiri] = [3, 6, 12]
    end

    if params[:installment]['bca']
      vtweb_options[:payment_options][:installment][:installment_terms][:bca] = [3, 6, 12]
    end
  end

  if request.env["HTTP_REFERER"]
    vtweb_options[:finish_redirect_url] = request.env["HTTP_REFERER"]
    vtweb_options[:unfinish_redirect_url] = request.env["HTTP_REFERER"]
    vtweb_options[:error_redirect_url] = request.env["HTTP_REFERER"]
  end

  @cahrge_params = {
    payment_type: "VTWEB",
    vtweb: vtweb_options,
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: 100_000
    },
    item_details: [
      name: "Mountain Apple",
      price: 2_000,
      quantity: 50
    ]
  }

  @result = Veritrans.charge(@cahrge_params)

  if @result.redirect_url
    if params[:locale].to_s != ""
      @vtweb_url = "#{@result.redirect_url}?locale=#{params[:locale]}"
    else
      @vtweb_url = @result.redirect_url
    end
  end

  erb :response
end

get "/check_points/:token_id" do
  @result = Veritrans.inquiry_points(params[:token_id])
  content_type :json
  @result.response.body
end

post "/webhook" do
  post_body = request.body.read
  request_data = Veritrans.decode_notification_json(post_body)

  #puts "Recieved #{post_body.size} bytes"
  #p request_data

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
