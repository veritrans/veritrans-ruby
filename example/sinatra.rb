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

get "/recurring" do
  erb :recurring
end

get "/localization" do
  erb :localization
end

post "/charge_vtdirect" do
  @result = Veritrans.charge(
    payment_type: "credit_card",
    credit_card: {
      token_id: params[:token_id],
      recurring: params[:recurring] == "1"
    },
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: params[:gross_amount]
    }
  )

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
  end

  @cahrge_params = {
    payment_type: "VTWEB",
    vtweb: vtweb_options,
    transaction_details: {
      order_id: generate_order_id,
      gross_amount: 100_000
    }
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
