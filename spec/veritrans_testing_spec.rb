describe Veritrans::Testing do

  before do
    hide_const("Rails")
    #Veritrans.logger = Logger.new("/dev/null")
    Veritrans.setup do
      config.load_config "./spec/configs/real_key.yml"
    end
  end

  it "It should pay Peramata VA txn", vcr: false do
    txn_result = Veritrans.charge("permata", transaction: { order_id: Time.now.to_s, gross_amount: 100_000 })
    txn_result.success?.should == true
    txn_result.status_message.should == "Success, PERMATA VA transaction is successful"

    result = Veritrans::Testing.pay_permata_va(txn_result.permata_va_number)

    result.should == {
      "status_code" => "00",
      "amount" => "100000.00",
      "status" => "SUCCESS",
      "message" => "Success Permata VA Payemnt",
      "cust_name" => "pasha testing2"
    }

    status_result = Veritrans.status(txn_result.order_id)
    status_result.transaction_status.should == 'settlement'
  end

  it "should pay for klik bca", vcr: false do
    txn_result = Veritrans.charge("bca_klikbca",
      bca_klikbca: {user_id: 'testuser123', description: "Test txn"},
      transaction: { order_id: Time.now.to_s, gross_amount: 100_000 }
    )

    result = Veritrans::Testing.pay_klik_bca('1234000937', 'testuser123', txn_result.order_id)

    status_result = nil
    # sometimes status is still pending for short amount of time, after payment is done
    3.times do
      status_result = Veritrans.status(txn_result.order_id)
      break if status_result.transaction_status == 'settlement'
      sleep 0.3
    end
    status_result.transaction_status.should == 'settlement'
  end

  it "should get cimb clicks txn info", vcr: false do
    pending "mami bug"

    txn_result = Veritrans.charge("cimb_clicks",
      cimb_clicks: { description: "My Payment" },
      transaction: { order_id: Time.now.to_s, gross_amount: 100_000 }
    )

    cimb_txn = Veritrans::Testing.get_cimb_clicks(txn_result.redirect_url)

    cimb_txn['status'].should == 'SUCCESS'
  end

  it "should pay cimb clicks txn", vcr: false do
    txn_result = Veritrans.charge("cimb_clicks",
      cimb_clicks: { description: "My Payment" },
      transaction: { order_id: Time.now.to_s, gross_amount: 100_000 }
    )

    #p txn_result.redirect_url

    cimb_txn = Veritrans::Testing.pay_cimb_clicks(txn_result.redirect_url)

    #p cimb_txn
  end

end