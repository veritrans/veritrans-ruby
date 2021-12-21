require 'veritrans'

# This is just for very basic implementation reference, in production, you should validate the incoming requests and implement your backend more securely.

# Set Midtrans config
# You can find it in Merchant Portal -> Settings -> Access keys
Midtrans.config.server_key = "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2"
Midtrans.config.client_key = "SB-Mid-client-ArNfhrh7st9bQKmz"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

# prepare CORE API parameter ( refer to: https://api-docs.midtrans.com/#create-pay-account ) create pay account parameter example
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
active_account_id = "7501d1f5-697c-4b4b-b095-69e60003759f"

# Get payment account by account id
result_get_account = Midtrans.get_payment_account(active_account_id)
puts "Get pay account response : #{result_get_account.data}"
# sample response :
# {
# 	: status_code => "200",: payment_type => "gopay",: account_id => "7501d1f5-697c-4b4b-b095-69e60003759f",: account_status => "ENABLED",: metadata => {
# 		"payment_options" => [{
# 			"name" => "GOPAY_WALLET",
# 			"active" => true,
# 			"balance" => {
# 				"value" => "8000000.00", "currency" => "IDR"
# 			},
# 			"metadata" => {},
# 			"token" => "de60838a-4fb7-48af-89b8-4741ba8e5404"
# 		}, {
# 			"name" => "PAY_LATER",
# 			"active" => true,
# 			"balance" => {
# 				"value" => "8000000.00", "currency" => "IDR"
# 			},
# 			"metadata" => {},
# 			"token" => "5b141678-7dc3-4f36-a5ec-c74ce62d2c46"
# 		}]
# 	}
# }

# request charge
params = {
  "payment_type": "gopay",
  "gopay": {
    "account_id": active_account_id,
    "payment_option_token": "de60838a-4fb7-48af-89b8-4741ba8e5404",
    "callback_url": "https://mywebstore.com/gopay-linking-finish"
  },
  "transaction_details": {
    "gross_amount": 10000,
    "order_id": "Gopaylink-sample-#{Time.now.to_i}"
  }
}

result_charge = Midtrans.charge(params)
puts "charge response : #{result_charge.data}"
# sample response
# {
# 	: status_code => "200",
# 	: status_message => "Success, GoPay transaction is successful",
# 	: transaction_id => "704c684b-7fa1-469b-93b0-5dab9e34985c",
# 	: order_id => "Gopaylink-sample-1639631080",
# 	: merchant_id => "G686051436",
# 	: gross_amount => "10000.00",
# 	: currency => "IDR",
# 	: payment_type => "gopay",
# 	: transaction_time => "2021-12-16 12:04:41",
# 	: transaction_status => "settlement",
# 	: fraud_status => "accept",
# 	: settlement_time => "2021-12-16 12:04:41"
# }

# unlink payment account by accountId
# when account status still PENDING, you will get status code 412
# sample response :
#   {
#        "status_code": "412",
#        "status_message": "Account status cannot be updated.",
#        "id": "358fdb22-1be2-4e6d-888d-b6703d60af6e"
#  }
result_unlink = Midtrans.unlink_payment_account(active_account_id)
puts "Unlink response : #{result_unlink.data}"