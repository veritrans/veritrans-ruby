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
        order_id: "ruby-lib-test-#{Time.now.to_i}",
        gross_amount: 200000
      },
      "credit_card": {
        "secure": true
      }
    )
    assert_equal 201, result.status_code
  end

  def test_snap_invalid_serverkey
    @mt_test_invalid_key = Veritrans.new(
      server_key: "invalid server key",
      client_key: "invalid client key",
      api_host: "https://api.sandbox.midtrans.com",
      logger: Logger.new(STDOUT),
      file_logger: Logger.new(STDOUT)
    )

    result = @mt_test_invalid_key.create_widget_token(
      transaction_details: {
        order_id: "ruby-lib-test-#{Time.now.to_i}",
        gross_amount: 200000
      },
      "credit_card": {
        "secure": true
      }
    )
    assert_equal 401, result.status_code
    assert_equal ["Access denied due to unauthorized transaction, please check client or server key", "Visit https://snap-docs.midtrans.com/#request-headers for more details"], result.error_messages
  end

  end
