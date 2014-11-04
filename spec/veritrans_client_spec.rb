describe Veritrans do

  before do
    hide_const("Rails")
    Veritrans.logger = Logger.new("/dev/null")
    Veritrans.setup do
      config.load_config "./example/veritrans.yml#development"
    end
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

end