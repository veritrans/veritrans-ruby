require 'veritrans'

# This is just for very basic implementation reference, in production, you should validate the incoming requests and implement your backend more securely.

# Set Midtrans config
# You can find it in Merchant Portal -> Settings -> Access keys
Midtrans.config.server_key = "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2"
Midtrans.config.client_key = "SB-Mid-client-ArNfhrh7st9bQKmz"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

# prepare CORE API parameter ( refer to: https://api-docs.midtrans.com/#create-pay-account ) create pay account parameter example
begin
parameter = {
  "payment_type": "gopay",
  "gopay_partner": {
    "phone_number": "81987654321",
    "country_code": "62",
    "redirect_url": "https://www.gojek.com"
  }
}

# link payment account
result = Midtrans.link_payment_account(parameter)
puts "Create pay account response : #{result.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end
# sample response :
# {
# 	: status_code => "201",: payment_type => "gopay",: account_id => "7501d1f5-697c-4b4b-b095-69e60003759f",: account_status => "PENDING",: actions => [{
# 		"name" => "activation-deeplink",
# 		"method" => "GET",
# 		"url" => "https://api.sandbox.midtrans.com/v2/pay/account/gpar_a5f424d0-c215-4633-b72d-6cac3bbc4328/link"
# 	}, {
# 		"name" => "activation-link-url",
# 		"method" => "GET",
# 		"url" => "https://api.sandbox.midtrans.com/v2/pay/account/gpar_a5f424d0-c215-4633-b72d-6cac3bbc4328/link"
# 	}, {
# 		"name" => "activation-link-app",
# 		"method" => "GET",
# 		"url" => "https://simulator.sandbox.midtrans.com/gopay/partner/web/otp?id=1cf353e9-d2ba-44e3-b6dc-00b2eb706ca9"
# 	}],: metadata => {
# 		"reference_id" => "d7e7cabe-a516-442f-b97a-230249cd62d0"
# 	}
# }
# for the first link, the account status is PENDING, you must activate it by accessing one of the URLs on the actions object

# Sample active account id for testing purpose
active_account_id = "bf45fd32-c379-4ef1-8ef6-b51c81da0204"
active_account_id_2 = "7501d1f5-697c-4b4b-b095-69e60003759f"

# Get payment account by account id
begin
result_get_account = Midtrans.get_payment_account(active_account_id)
puts "Get pay account response : #{result_get_account.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end
# sample response :
# {
#   : status_code => "200",: payment_type => "gopay",: account_id => "bf45fd32-c379-4ef1-8ef6-b51c81da0204",: account_status => "ENABLED",: metadata => {
#   "payment_options" => [{
#   "name" => "GOPAY_WALLET",
#   "active" => true,
#   "balance" => {
#     "value" => "8000000.00", "currency" => "IDR"
#   },
#   "metadata" => {},
#   "token" => "ebce5a0a-69d0-4961-bb23-390a9df9f4f9"
# }, {
#   "name" => "PAY_LATER",
#   "active" => true,
#   "balance" => {
#     "value" => "8000000.00", "currency" => "IDR"
#   },
#   "metadata" => {},
#   "token" => "0272b39c-13bb-4aba-be68-74074f85aa86"
# }]
# }
# }

# sample param request charge
begin
params = {
  "payment_type": "gopay",
  "gopay": {
    "account_id": active_account_id,
    "payment_option_token": "0272b39c-13bb-4aba-be68-74074f85aa86",
    "callback_url": "https://mywebstore.com/gopay-linking-finish"
  },
  "transaction_details": {
    "gross_amount": 1000,
    "order_id": "Gopaylink-sample-#{Time.now.to_i}"
  }
}
# sample request charge
result_charge = Midtrans.charge(params)
puts "charge response : #{result_charge.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end

# sample charge response
# {
#   : status_code => "200",
#   : status_message => "Success, GoPay transaction is successful",
#   : transaction_id => "55de5840-99f1-4b1d-a5fb-1b48d4ab321c",
#   : order_id => "Gopaylink-sample-1641270143",
#   : merchant_id => "G686051436",
#   : gross_amount => "10000.00",
#   : currency => "IDR",
#   : payment_type => "gopay",
#   : transaction_time => "2022-01-04 11:22:24",
#   : transaction_status => "settlement",
#   : fraud_status => "accept",
#   : settlement_time => "2022-01-04 11:22:24"
# }

# unlink payment account by accountId
# when account status still PENDING, you will get status code 412
# sample response :
#   {
#        "status_code": "412",
#        "status_message": "Account status cannot be updated.",
#        "id": "358fdb22-1be2-4e6d-888d-b6703d60af6e"
#  }
begin
result_unlink = Midtrans.unlink_payment_account(active_account_id_2)
puts "Unlink response : #{result_unlink.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end