require 'veritrans'

# This is just for very basic implementation reference, in production, you should validate the incoming requests and implement your backend more securely.

# Set Midtrans config
# You can find it in Merchant Portal -> Settings -> Access keys
Midtrans.config.server_key = "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2"
Midtrans.config.client_key = "SB-Mid-client-ArNfhrh7st9bQKmz"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

# IMPORTANT NOTE: You should do credit card get token via frontend using `midtrans-new-3ds.min.js`, to avoid card data breach risks on your backend
# ( refer to: https://docs.midtrans.com/en/core-api/credit-card?id=_1-getting-the-card-token )
# For full example on Credit Card 3DS transaction refer to:
# (/example/sinatra) that implement Snap & Core Api

# prepare CORE API parameter to get credit card token
# another sample of card number can refer to https://docs.midtrans.com/en/technical-reference/sandbox-test?id=card-payments
card = {
  card_number: 5211111111111117,
  card_cvv: 123,
  card_exp_month: 12,
  card_exp_year: 2025
}
get_token = Midtrans.create_card_token(card)

# prepare CORE API parameter to charge credit card ( refer to: https://docs.midtrans.com/en/core-api/credit-card?id=_2-sending-transaction-data-to-charge-api )
result = Midtrans.charge(
  {
    "payment_type": "credit_card",
    "transaction_details": {
      "gross_amount": 10000,
      "order_id": "ruby-example-coreapi-creditcard-#{Time.now.to_i}"
    },
    "credit_card": {
      "token_id": "#{get_token.token_id}"
    }
  }
)

puts result.data

# result.data this will be Hash representation of the API JSON response, of example:
# {
# : status_code => "200",
# : status_message => "Success, Credit Card transaction is successful",
# : channel_response_code => "00",
# : channel_response_message => "Approved",
# : bank => "bni",
# : transaction_id => "21386a6e-6e26-4191-9d05-877aa6063c08",
# : order_id => "ruby-example-coreapi-creditcard-1634014338",
# : merchant_id => "G686051436",: gross_amount => "10000.00",
# : currency => "IDR",
# : payment_type => "credit_card",
# : transaction_time => "2021-10-12 11:52:18",
# : transaction_status => "capture",
# : fraud_status => "accept",
# : approval_code => "1634014339258",
# : masked_card => "521111-1117",
# : card_type => "debit"
# }