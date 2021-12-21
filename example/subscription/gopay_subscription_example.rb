require 'veritrans'

# This is just for very basic implementation reference, in production, you should validate the incoming requests and implement your backend more securely.

# Set Midtrans config
# You can find it in Merchant Portal -> Settings -> Access keys
Midtrans.config.server_key = "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2"
Midtrans.config.client_key = "SB-Mid-client-ArNfhrh7st9bQKmz"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

# To use API subscription for gopay, you should first link your customer gopay account with gopay tokenization
# Refer to this docs: https://api-docs.midtrans.com/#gopay-tokenization

# You will receive gopay payment token using `get_payment_account` API call.
# You can see some Tokenization API examples here (examples/tokenization)
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
# Sample gopay payment option token and gopay account id for testing purpose that has been already activated before
gopay_payment_option_token = "de60838a-4fb7-48af-89b8-4741ba8e5404"
gopay_account_id = "7501d1f5-697c-4b4b-b095-69e60003759f"

# prepare CORE API parameter ( refer to: https://api-docs.midtrans.com/#create-subscription ) create subscription parameter example
parameter = {
  "name": "SUBS-Gopay-2021",
  "amount": "10000",
  "currency": "IDR",
  "payment_type": "gopay",
  "token": gopay_payment_option_token,
  "schedule": {
    "interval": 1,
    "interval_unit": "day",
    "max_interval": 7
  },
  "metadata": {
    "description": "Recurring payment for A"
  },
  "customer_details": {
    "first_name": "John A",
    "last_name": "Doe A",
    "email": "johndoe@email.com",
    "phone": "+62812345678"
  },
  "gopay": {
    "account_id": gopay_account_id
  }
}

result = Midtrans.create_subscription(parameter)
puts "Create subscription response : #{result.data}"
# result.data this will be Hash representation of the API JSON response
# {
# 	: id => "c04d89cb-ece6-4419-a87a-f773b243760d",
# 	: name => "SUBS-Gopay-2021",
# 	: amount => "10000",
# 	: currency => "IDR",
# 	: created_at => "2021-12-17 11:05:16",
# 	: schedule => {
# 		"interval" => 1, "current_interval" => 0, "max_interval" => 7, "interval_unit" => "day", "start_time" => "2021-12-17 11:05:16", "previous_execution_at" => "2021-12-17 11:05:16", "next_execution_at" => "2021-12-18 11:05:16"
# 	},
# 	: status => "active",
# 	: token => "de60838a-4fb7-48af-89b8-4741ba8e5404",
# 	: payment_type => "gopay",
# 	: transaction_ids => [],
# 	: metadata => {
# 		"description" => "Recurring payment for A"
# 	},
# 	: customer_details => {
# 		"email" => "johndoe@email.com", "first_name" => "John A", "last_name" => "Doe A", "phone" => "+62812345678"
# 	}
# }

# sample active subscription id for testing purpose
subscription_id = "c04d89cb-ece6-4419-a87a-f773b243760d"

# get subscription by subscription_id
result_get_subs = Midtrans.get_subscription(subscription_id)
puts "get subscription response : #{result_get_subs.data}"

# enable subscription by subscription_id
result_enable_subs = Midtrans.enable_subscription(subscription_id)
puts "enable subscription response : #{result_enable_subs.data}"

# update subscription by subscription_id and update_subscription_param
update_subscription_param = {
  "name": "MONTHLY_2021",
  "amount": "300000",
  "currency": "IDR",
  "token": gopay_payment_option_token,
  "schedule": {
    "interval": 1
  }
}

result_update_subs = Midtrans.update_subscription(subscription_id, update_subscription_param)
puts "update subscription response : #{result_update_subs.data}"

# disable subscription by subscription_id
result_disable_subs = Midtrans.disable_subscription(subscription_id)
puts "disable subscription response : #{result_disable_subs.data}"