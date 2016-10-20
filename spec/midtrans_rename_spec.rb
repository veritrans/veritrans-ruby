describe Veritrans::Client do

  before do
    hide_const("Rails")
    Midtrans.logger = Logger.new("/dev/null")
    Midtrans.setup do
      config.load_config "./spec/configs/real_key.yml"
    end
  end

  it "should create alias constant for Midtrans" do
    Midtrans.should == Veritrans
  end

  it "should work with Midtrans" do
    VCR.use_cassette('midtrans_status') do
      txn_result = Veritrans.charge("permata", transaction: { order_id: Time.now.to_s, gross_amount: 100_000 })
      txn_result.success?.should == true
      txn_result.status_message.should == "Success, PERMATA VA transaction is successful"

      cancel_result = Midtrans.status(txn_result.order_id)
      cancel_result.success?.should == true
      cancel_result.status_message.should == "Success, transaction is found"
    end
  end

end