describe Veritrans do

  before do
    stub_const("CONFIG", {})

    stub_request(:any, /.*example.*/).to_return(lambda { |req|
      @request = req
      {body: "ok", status: 200}
    })
  end

  it "should send json" do
    silence_stream(STDOUT) do
      Veritrans::CLI.test_webhook(["http://example.com"])
    end

    data = ActiveSupport::JSON.decode(@request.body)
    data.class.should == String
    data = ActiveSupport::JSON.decode(data)

    data["status_code"].should == "200"
    data["status_message"].should == "Veritrans payment notification"
    data["payment_type"].should == "credit_card"

    @request.headers["Content-Type"].should == "application/json"
    @request.headers["User-Agent"].should == "Veritrans gem #{Veritrans::VERSION} - webhook tester"
  end

  it "should raise error if payment not found" do
    CONFIG[:order] = "1111-not-exists"
    CONFIG[:config_path] = "./example/veritrans.yml"

    VCR.use_cassette("cli_test_not_exists") do
      silence_stream(STDOUT) do
        expect {
          Veritrans::CLI.test_webhook(["http://example.com"])
        }.to raise_error(Veritrans::CLI::OrderNotFound)
      end
    end
  end

  it "should raise error if can't find config" do
    CONFIG[:order] = "1111-not-exists"
    CONFIG[:config_path] = "./wrong/folder/veritrans.yml"

    silence_stream(STDOUT) do
      expect {
        Veritrans::CLI.test_webhook(["http://example.com"])
      }.to raise_error(ArgumentError, /Can not find config at .+/)
    end
  end

  it "should raise error if authentication failed" do
    CONFIG[:order] = "1111-not-exists"
    CONFIG[:config_path] = "./spec/configs/veritrans.yml"

    VCR.use_cassette("cli_test_unauthorized") do
      silence_stream(STDOUT) do
        expect {
          Veritrans::CLI.test_webhook(["http://example.com"])
        }.to raise_error(Veritrans::CLI::AuthenticationError, /Access denied due to unauthorized transaction/)
      end
    end
  end

  it "should send real data as json" do
    CONFIG[:order] = "testing-0.2703-1415600236"
    CONFIG[:config_path] = "./example/veritrans.yml"

    VCR.use_cassette("cli_test_real_txn") do
      silence_stream(STDOUT) do
        Veritrans::CLI.test_webhook(["http://example.com"])
      end
    end

    data = ActiveSupport::JSON.decode(@request.body)
    data.class.should == String
    data = ActiveSupport::JSON.decode(data)

    data["status_code"].should == "200"
    data["status_message"].should == "Veritrans payment notification"
    data["payment_type"].should == "credit_card"
    data["transaction_status"].should == "settlement"
    data["approval_code"].should == "1415600254322"
  end
end