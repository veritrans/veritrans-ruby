require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Veritrans::VTDirect do

  before do
    @client = Veritrans::VTDirect.new
    @old_constant = Veritrans::Config::SERVER_HOST
    Veritrans::Config.send(:remove_const,'SERVER_HOST') 
    Veritrans::Config.const_set('SERVER_HOST', "http://192.168.10.250:8080") 
  end

  after do
    Veritrans::Config.send(:remove_const,'SERVER_HOST') 
    Veritrans::Config.const_set('SERVER_HOST', @old_constant) 
  end

  describe "#charges" do
    it "return json success" do 
      address = {
             first_name: "Sam",
             last_name: "Anthony",
             address1: "Buaran I",
             address2: "Pulogadung",
             city: "Jakarta",
             country_code: "IDN",
             postal_code: "16954",
             phone: "0123456789123"           
           }
      @client.token_id    = "Jlomia5ycElw5t6QsTexJQ=="
      @client.order_id    = "order_5"
      @client.order_items = [
              {
                 id: "10",
                 price: 100,
                 qty: 1,
                 name1: "Mie",
                 name2: "Goreng"
              },
              {
                 id: "11",
                 price: 100,
                 qty: 1,
                 name1: "Mie",
                 name2: "Kuah"
              }
           ]
      @client.gross_amount = 200
      @client.email     = "echo.khannedy@gmail.com"
      @client.shipping_address = address
      @client.billing_address  = address
      VCR.use_cassette('charges_POST') do
        @client.stub(:server_host,"http://veritrans.dev") do 
          result = JSON.parse(@client.charges)
          result["status"].must_equal("success")
        end
      end
    end
    # @client.charges
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
  end

  describe "#common method from config" do
    it "return value from config" do
      %w[server_key server_host].each do |key|
        old_value = Veritrans::Client.config[key]
        Veritrans::Client.config[key] = "lol"
        @client.send(key).must_equal("lol")
        Veritrans::Client.config[key] = old_value
      end
    end

    it "return value from config" do
      %w[server_key].each do |key|
        old_value = Veritrans::Client.config[key]
        @client.send("#{key}=","lol")
        Veritrans::Client.config[key].must_equal("lol")
        Veritrans::Client.config[key] = old_value
      end
    end
  end

  describe "#token from instance" do 
  end

end