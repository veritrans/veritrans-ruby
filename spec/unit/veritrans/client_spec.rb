require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Veritrans::Client do

  before do
    @client = Veritrans::Client.new
    @old_constant = Veritrans::Config::SERVER_HOST
    Veritrans::Config.send(:remove_const,'SERVER_HOST') 
    Veritrans::Config.const_set('SERVER_HOST', "http://192.168.10.250:8080") 
  end

  after do
    Veritrans::Config.send(:remove_const,'SERVER_HOST') 
    Veritrans::Config.const_set('SERVER_HOST', @old_constant) 
  end

  describe "#get_keys" do
    it "return value from veritrans http_post" do 
      @client.order_id      = "81797068"
      @client.session_id    = "89718576"
      @client.gross_amount  = "10"
      @client.commodity     = [
        { "COMMODITY_ID"    => "IDxx1", 
          "COMMODITY_UNIT"  => "10", 
          "COMMODITY_NUM"   => "1", 
          "COMMODITY_NAME1" => "Waterbotle", 
          "COMMODITY_NAME2" => "Waterbottle in Indonesian" }
      ]
      @client.shipping_flag         = "1"
      @client.shipping_first_name   = "Sam"
      @client.shipping_last_name    = "Anthony"
      @client.shipping_address1     = "Buaran I" 
      @client.shipping_address2     = "Pulogadung"
      @client.shipping_city         = "Jakarta"
      @client.shipping_country_code = "IDN"
      @client.shipping_postal_code  = "16954"
      @client.shipping_phone        = "0123456789123"
      @client.shipping_method       = "N"
      VCR.use_cassette('get_keys_POST') do
        @client.stub(:server_host,'https://payments.veritrans.co.id') do 
          @client.get_keys.must_equal({
            "TOKEN_MERCHANT" => "FI06SsaC7kzanHsENigDk9y4KTSLt9DhFT7uu1e4mYMEcJcAoL", 
            "TOKEN_BROWSER"  => "sUK9EYWq8JE5nsrTkI0X1NgQ2jqqlJOyViYfHGeWnOjZTYMLRT"})
        end
      end
    end

    it "return value from veritrans http_post" do 
      old_value = Veritrans::Client.config["server_host"]
      Veritrans::Client.config["server_host"] = 'https://payments.veritrans.co.id'
      VCR.use_cassette('get_keys_POST') do
        @client1 = Veritrans::Client.new do |me|
          me.order_id      = "81797068"
          me.session_id    = "89718576"
          me.gross_amount  = "10"
          me.commodity     = [
            { "COMMODITY_ID"    => "IDxx1", 
              "COMMODITY_UNIT"  => "10", 
              "COMMODITY_NUM"   => "1", 
              "COMMODITY_NAME1" => "Waterbotle", 
              "COMMODITY_NAME2" => "Waterbottle in Indonesian" }
          ]
          me.shipping_flag         = "1"
          me.shipping_first_name   = "Sam"
          me.shipping_last_name    = "Anthony"
          me.shipping_address1     = "Buaran I" 
          me.shipping_address2     = "Pulogadung"
          me.shipping_city         = "Jakarta"
          me.shipping_country_code = "IDN"
          me.shipping_postal_code  = "16954"
          me.shipping_phone        = "0123456789123"
          me.shipping_method       = "N"
        end
      end
      @client1.token.must_equal({
      "TOKEN_MERCHANT" => "FI06SsaC7kzanHsENigDk9y4KTSLt9DhFT7uu1e4mYMEcJcAoL", 
      "TOKEN_BROWSER"  => "sUK9EYWq8JE5nsrTkI0X1NgQ2jqqlJOyViYfHGeWnOjZTYMLRT"})
      Veritrans::Client.config["server_host"] = old_value
    end

  end

  describe "#server_host" do
    it "return server host from config" do
      Veritrans::Client.config["server_host"] = "http://192.168.10.250:80"
      @client.server_host.must_equal("http://192.168.10.250:80")
    end

    it "return server host from constants" do
      old_value = Veritrans::Client.config["server_host"]
      Veritrans::Client.config["server_host"] = nil
      @client.server_host.must_equal("http://192.168.10.250:8080")
      Veritrans::Client.config["server_host"] = old_value
    end
  end

  describe "#redirect_url" do
    it "returns redirect url path" do
      @client.stub :server_host,"http://192.168.10.250:80" do 
        @client.redirect_url.must_equal("http://192.168.10.250:80/web1/paymentStart.action")
      end
    end
  end

  describe "#common method from config" do
    it "return value from config" do
      %w[merchant_hash_key merchant_id error_payment_return_url finish_payment_return_url unfinish_payment_return_url].each do |key|
        old_value = Veritrans::Client.config[key]
        Veritrans::Client.config[key] = "lol"
        @client.send(key).must_equal("lol")
        Veritrans::Client.config[key] = old_value
      end
    end

    it "return value from config" do
      %w[merchant_hash_key merchant_id].each do |key|
        old_value = Veritrans::Client.config[key]
        @client.send("#{key}=","lol")
        Veritrans::Client.config[key].must_equal("lol")
        Veritrans::Client.config[key] = old_value
      end
    end
  end

  describe "#token from instance" do 
    it "return value from instance" do 
      old_value = @client.instance_eval("@token")
      @client.instance_eval("@token='lol'")
      @client.token.must_equal('lol')
      @client.instance_eval("@token='#{old_value}'")
    end
  end

end