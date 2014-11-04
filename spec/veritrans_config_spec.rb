describe Veritrans::Config do

  before do
    hide_const("Rails")
  end

  it "should set Veritras as self inside config block" do
    Veritrans.config do
      self.should == Veritrans
    end
  end

  it "should have sandbox api_host by defualt" do
    Veritrans.config.api_host.should == "https://api.sandbox.veritrans.co.id"
  end

  it "should set client key and server key" do
    Veritrans.config do
      config.client_key = "kk-1"
      config.server_key = "sk-1"
    end

    Veritrans.config.client_key.should == "kk-1"
    Veritrans.config.server_key.should == "sk-1"
  end

  it "should load config" do
    data = Veritrans.config.load_config("./spec/configs/veritrans_flat.yml")
    data.should == {"client_key" => "flat_client_key", "server_key" => "flat_server_key"}
  end

  it "should load config according to hash" do
    data = Veritrans.config.load_config("./spec/configs/veritrans.yml#development")
    data.should == {"client_key" => "spec_client_key", "server_key" => "spec_server_key"}
  end

  it "should load config for Rails.env" do
    stub_const("Rails", Class.new {
      def self.env
        "test"
      end
    })

    data = Veritrans.config.load_config("./spec/configs/veritrans.yml")
    data.should == {"client_key" => "test_client_key", "server_key" => "test_server_key"}
  end

end