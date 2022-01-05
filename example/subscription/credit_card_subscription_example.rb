require 'veritrans'

# This is just for very basic implementation reference, in production, you should validate the incoming requests and implement your backend more securely.

# Set Midtrans config
# You can find it in Merchant Portal -> Settings -> Access keys
Midtrans.config.server_key = "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2"
Midtrans.config.client_key = "SB-Mid-client-ArNfhrh7st9bQKmz"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

# To use API subscription for credit card, you should first obtain the 1 click token
# Refer to this docs: https://docs.midtrans.com/en/core-api/advanced-features?id=recurring-transaction-with-subscriptions-api

# You will receive saved_token_id as part of the response when the initial card payment is accepted (will also available in the HTTP notification's JSON)
# Refer to this docs: https://docs.midtrans.com/en/core-api/advanced-features?id=sample-3ds-authenticate-json-response-for-the-first-transaction
# {
# .
# "status_code": "200",
# "signature_key": "02d88dbe3ea009934daae63f0ec10b3078f92bbd75139cc9834689b92e707d305fb04b079020e877703c5ddbfbd779d5e2f62dc6edd63b0e68edeb57a985cf38",
# "saved_token_id_expired_at": "2025-12-31 07:00:00",
# "saved_token_id": "521111eLfszZpPoDAxJEjmoYCuaR1117",
# .
# }
# Sample saved token id for testing purpose
saved_token_id = "521111eLfszZpPoDAxJEjmoYCuaR1117"

# prepare parameter ( refer to: https://api-docs.midtrans.com/#create-subscription ) create subscription parameter example
begin
parameter = {
  "name": "MONTHLY_2021",
  "amount": "14000",
  "currency": "IDR",
  "payment_type": "credit_card",
  "token": saved_token_id,
  "schedule": {
    "interval": 1,
    "interval_unit": "month",
    "max_interval": 12,
    "start_time": "2022-12-20 07:00:00 +0700"
  },
  "metadata": {
    "description": "Recurring payment for A"
  },
  "customer_details": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "johndoe@email.com",
    "phone": "+62812345678"
  }
}

result = Midtrans.create_subscription(parameter)
puts "Create subscription response : #{result.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end
# result.data this will be Hash representation of the API JSON response
# {
# 	: id => "1d9c15ea-13e2-43f3-a87b-90aad6a9ad95",
# 	: name => "MONTHLY_2021",
# 	: amount => "14000",
# 	: currency => "IDR",
# 	: created_at => "2021-12-16 13:19:25",
# 	: schedule => {
# 		"interval" => 1, "current_interval" => 0, "max_interval" => 12, "interval_unit" => "month", "start_time" => "2021-12-20 07:00:00", "next_execution_at" => "2021-12-20 07:00:00"
# 	},
# 	: status => "active",
# 	: token => "521111eLfszZpPoDAxJEjmoYCuaR1117",
# 	: payment_type => "credit_card",
# 	: transaction_ids => [],
# 	: metadata => {
# 		"description" => "Recurring payment for A"
# 	},
# 	: customer_details => {
# 		"email" => "johndoe@email.com", "first_name" => "John", "last_name" => "Doe", "phone" => "+62812345678"
# 	}
# }

# Sample active subscription id for testing purpose
subscription_id = "1d9c15ea-13e2-43f3-a87b-90aad6a9ad95"

# get subscription by subscription_id
begin
result_get_subs = Midtrans.get_subscription(subscription_id)
puts "get subscription response : #{result_get_subs.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end

# enable subscription by subscription_id
begin
result_enable_subs = Midtrans.enable_subscription(subscription_id)
puts "enable subscription response : #{result_enable_subs.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end

# update subscription by subscription_id and update_subscription_param
begin
update_subscription_param = {
  "name": "MONTHLY_2022",
  "amount": "300000",
  "currency": "IDR",
  "token": saved_token_id,
  "schedule": {
    "interval": 1
  }
}

result_update_subs = Midtrans.update_subscription(subscription_id, update_subscription_param)
puts "update subscription response : #{result_update_subs.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end

# disable subscription by subscription_id
begin
result_disable_subs = Midtrans.disable_subscription(subscription_id)
puts "disable subscription response : #{result_disable_subs.data}"
rescue MidtransError => e
  puts e.message # Basic message error
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end