describe Veritrans do

  before do
    hide_const("Rails")
    Veritrans.logger = Logger.new("/dev/null")
    Veritrans.setup do
      config.load_config "./spec/configs/real_key.yml"
    end
  end

  it "should use Veritrans.http_options", vcr: false do
    Veritrans::Config.stub(:http_options) do
      { omit_default_port: true }
    end

    api_request = nil
    stub_request(:any, /.*/).to_return(lambda { |request|
      api_request = request
      {body: request.body}
    })

    result = Veritrans.request_with_logging(:get, Veritrans.config.api_host + "/ping", {})

    api_request.headers["Host"].should == "api.sandbox.veritrans.co.id"
  end

  it "should use Veritrans.http_options to attach hedaers", vcr: false do
    Veritrans::Config.stub(:http_options) do
      { headers: { "X-Rspec" => "ok" } }
    end

    api_request = nil
    stub_request(:any, /.*/).to_return(lambda { |request|
      api_request = request
      {body: request.body}
    })

    result = Veritrans.request_with_logging(:get, Veritrans.config.api_host + "/ping", {})

    api_request.headers["X-Rspec"].should == "ok"
  end

  it "should send charge vt-web request" do
    VCR.use_cassette('charge_vtweb') do
      result = Veritrans.charge('vtweb', transaction: { order_id: Time.now.to_s, gross_amount: 100_000 } )

      result.status_message.should == "OK, success do VTWeb transaction, please go to redirect_url"
      result.success?.should == true
      result.redirect_url.should be_present
    end
  end

  it "should send charge vt-web request" do
    VCR.use_cassette('charge_direct') do
      result = Veritrans.charge("permata", transaction: { order_id: Time.now.to_s, gross_amount: 100_000 })

      result.status_message.should == "Success, PERMATA VA transaction is successful"
      result.success?.should == true
      result.permata_va_number.should be_present
    end
  end

  it "should send status request" do
    VCR.use_cassette('status_fail') do
      result = Veritrans.status("not-exists")
      result.success?.should == false
      result.status_message.should == "The requested resource is not found"
    end
  end

  it "should send status request and get response" do
    VCR.use_cassette('status_success') do
      result_charge = Veritrans.charge('permata', transaction: { order_id: Time.now.to_i, gross_amount: 100_000 } )
      result = Veritrans.status(result_charge.order_id)
      result.success?.should == true
      result.status_message.should == "Success, transaction found"
      result.transaction_status.should == "pending"
    end
  end

  it "should send status request and get response" do
    VCR.use_cassette('cancel_failed') do
      result = Veritrans.cancel("not-exists")
      result.success?.should == false
      result.status_message.should == "The requested resource is not found"
    end
  end

  it "should send status request and get response" do
    VCR.use_cassette('cancel_success') do
      result_charge = Veritrans.charge('permata', transaction: { order_id: Time.now.to_i, gross_amount: 100_000 } )
      result = Veritrans.cancel(result_charge.order_id)
      result.success?.should == true
      result.status_message.should == "Success, transaction is canceled"
      result.transaction_status.should == "cancel"
    end
  end

  it "should send approve request" do
    VCR.use_cassette('approve_failed') do
      result = Veritrans.cancel("not-exists")
      result.success?.should == false
      result.status_message.should == "The requested resource is not found"
    end
  end

  it "should send capture request" do
    VCR.use_cassette('capture_failed') do
      result = Veritrans.capture("not-exists", 1000)
      result.success?.should == false
      result.status_message.should == "The requested resource is not found"
    end
  end

  it "should send expire request" do
    VCR.use_cassette('expire_success', record: :once) do
      result = Veritrans.expire("af3fb136-c405-4103-9a36-5a6a9e2855a9")
      result.success?.should == true
      result.status_message.should == "Success, transaction has expired"
    end
  end

  it "should send expire request" do
    VCR.use_cassette('expire_failed', record: :once) do
      result = Veritrans.expire("not-exists")
      result.success?.should == false
      result.status_message.should == "The requested resource is not found"
    end
  end
end