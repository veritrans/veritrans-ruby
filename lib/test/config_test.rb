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

  def test_api_host
    assert_equal "https://api.sandbox.midtrans.com", Veritrans.config.api_host
  end

  def test_client_key_server_key
    Veritrans.config.client_key = "kk-1"
    Veritrans.config.server_key = "sk-1"

    assert_equal "kk-1", Veritrans.config.client_key
    assert_equal "sk-1", Veritrans.config.server_key
  end
end