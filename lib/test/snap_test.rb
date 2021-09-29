require 'veritrans'
require 'minitest/autorun'

class TestVeritrans < Minitest::Test

  def setup
    @mt_test = Veritrans.new(
      server_key: "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2",
      client_key: "SB-Mid-client-ArNfhrh7st9bQKmz",
      api_host: "https://api.sandbox.midtrans.com",
      logger: Logger.new(STDOUT),
      file_logger: Logger.new(STDOUT)
    )
  end

  def test_create_widget_token
    result = @mt_test.create_widget_token(
      transaction_details: {
        order_id: "THE-ITEM-ORDER-#{rand(1..10000)}",
        gross_amount: 200000
      },
      "credit_card": {
        "secure": true
      }
    )
    assert_equal 201, result.status_code
  end

  end
