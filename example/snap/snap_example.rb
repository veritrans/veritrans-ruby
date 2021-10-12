require 'veritrans'

# This is just for very basic implementation reference, in production, you should validate the incoming requests and implement your backend more securely.
# Please refer to this docs for snap popup:
# https://docs.midtrans.com/en/snap/integration-guide?id=integration-steps-overview

# Please refer to this docs for snap-redirect:
# https://docs.midtrans.com/en/snap/integration-guide?id=alternative-way-to-display-snap-payment-page-via-redirect

# Set Midtrans config
# You can find it in Merchant Portal -> Settings -> Access keys
Midtrans.config.server_key = "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2"
Midtrans.config.client_key = "SB-Mid-client-ArNfhrh7st9bQKmz"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

# Create snap transaction
result = Midtrans.create_snap_token(
  transaction_details: {
    order_id: "snap-example-test-#{Time.now.to_i}",
    gross_amount: 200000
  },
  "credit_card": {
    "secure": true
  }
)

puts result.data

# result.data this will be Hash representation of the API JSON response, of example:
# {
# : token => "008e586b-17f5-459f-8418-2764f08f1d8c",
# : redirect_url => "https://app.sandbox.midtrans.com/snap/v2/vtweb/008e586b-17f5-459f-8418-2764f08f1d8c"
# }