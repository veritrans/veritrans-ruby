describe Veritrans::Testing, skip: true do

  before do
    hide_const("Rails")
    #Veritrans.logger = Logger.new("/dev/null")
    Veritrans.setup do
      config.load_config "./spec/configs/real_key.yml"
    end
  end

  context "Peramata VA" do
    it "It should pay Peramata VA txn", vcr: false do
      txn_result = Veritrans.charge("bank_transfer",
        bank_transfer: {bank: "permata"},
        transaction_details: txn_details
      )
      txn_result.success?.should == true
      txn_result.status_message.should == "Success, PERMATA VA transaction is successful"

      result = Veritrans::Testing.pay_permata_va(txn_result.permata_va_number)

      result['status'].should == 'SUCCESS'
      assert_txn_status(txn_result.order_id, 'settlement')
    end
  end

  context "bca va" do
    it "should pay for BCA VA", vcr: false do
      txn_result = Veritrans.charge("bank_transfer",
        bank_transfer: {bank: "bca"},
        transaction_details: txn_details
      )
      va_number = txn_result.va_numbers[0]['va_number']

      result = Veritrans::Testing.pay_bca_va(va_number)

      result['status'].should == 'SUCCESS'
      assert_txn_status(txn_result.order_id, 'settlement')
    end
  end

  context "Mandiri Bill" do
    it "should pay for Mandiri Bill", vcr: false do
      txn_result = Veritrans.charge('echannel',
        echannel: {bill_info1: "Payment for", bill_info2: "Test txn"},
        transaction_details: txn_details,
        item_details: [ { id: 'a1', price: txn_details[:gross_amount], quantity: 1, name: 'Violin' } ]
      )

      result = Veritrans::Testing.pay_mandiri_bill(txn_result.bill_key)
      result['status'].should == 'SUCCESS'
      assert_txn_status(txn_result.order_id, 'settlement')
    end
  end

  context "klik bca" do
    it "should pay for klik bca", vcr: false do
      txn_result = Veritrans.charge("bca_klikbca",
        bca_klikbca: {user_id: 'testuser123', description: "Test txn"},
        transaction_details: txn_details
      )

      result = Veritrans::Testing.pay_klik_bca('1234000937', 'testuser123', txn_result.order_id)

      result['status'].should == 'SUCCESS'
      assert_txn_status(txn_result.order_id, 'settlement')
    end
  end

  context "indomaret" do
    it "should pay for indomaret transaction", vcr: false do
      txn_result = Veritrans.charge('cstore',
        cstore: {store: "Indomaret", message: "Buah Mangga"},
        transaction_details: txn_details
      )

      result = Veritrans::Testing.pay_indomaret(txn_result.payment_code)

      result['status'].should == 'SUCCESS'
      assert_txn_status(txn_result.order_id, 'settlement')
    end
  end

  context "cimb clicks" do
    it "should get cimb clicks txn info", vcr: false do

      txn_result = Veritrans.charge("cimb_clicks",
        cimb_clicks: { description: "My Payment" },
        transaction_details: txn_details
      )

      cimb_txn = Veritrans::Testing.get_cimb_clicks(txn_result.redirect_url)

      cimb_txn.should == {
        "status_code" => "00",
        "amount"      => "100000.00",
        "status"      => "SUCCESS",
        "user_email"  => "noreply@veritrans.co.id",
        "message"     => "Success Inquiry Cimb Clicks",
        "user_name"   => "Veritrans"
      }
    end

    it "should pay cimb clicks txn", vcr: false do
      txn_result = Veritrans.charge("cimb_clicks",
        cimb_clicks: { description: "My Payment" },
        transaction: { order_id: Time.now.to_s, gross_amount: 100_000 }
      )

      result = Veritrans::Testing.pay_cimb_clicks(txn_result.redirect_url)

      result['status'].should == 'SUCCESS'
      assert_txn_status(txn_result.order_id, 'settlement')
    end

    it "should reject cimb clicks txn with wrong user_id", vcr: false do
      txn_result = Veritrans.charge("cimb_clicks",
        cimb_clicks: { description: "My Payment" },
        transaction: { order_id: Time.now.to_s, gross_amount: 100_000 }
      )

      result = Veritrans::Testing.pay_cimb_clicks(txn_result.redirect_url, 'aaaa')

      result['status'].should == 'ERROR'
      assert_txn_status(txn_result.order_id, 'pending')
    end
  end

  context "SNAP" do
    it "should confirm snap payment", vcr: false do
      snap_txn_details = txn_details
      result = Veritrans.create_snap_token(transaction_details: snap_txn_details)

      snap_result = Veritrans::Testing.pay_snap(result.token, 'mandiri_clickpay', {
        payment_params: {
          mandiri_card_no: "4111111111111111",
          input3: 43044,
          token_response: '000000'
        }
      })

      snap_result['status_code'].should == '200'
      snap_result['transaction_status'].should == 'settlement'
      snap_result['finish_redirect_url'].should =~ /.+/

      assert_txn_status(snap_txn_details[:order_id], 'settlement')
    end

    it "should complete snap payment for permata VA", vcr: false do
      snap_txn_details = txn_details
      result = Veritrans.create_snap_token(transaction_details: snap_txn_details)

      snap_result = Veritrans::Testing.pay_snap(result.token, 'permata_va', {
        #customer_details: {
        #  email: "budi@utomo.com"
        #}
      })

      snap_result['status_code'].should == '201'
      snap_result['transaction_status'].should == 'pending'
      snap_result['permata_va_number'].should =~ /.+/

      result = Veritrans::Testing.pay_permata_va(snap_result['permata_va_number'])

      result['status'].should == 'SUCCESS'
      assert_txn_status(snap_txn_details[:order_id], 'settlement')
    end
  end

  def txn_details
    { order_id: "gem-testing-" + (Time.now.to_f * 1000).round.to_s(36), gross_amount: 100_000 }
  end

  def assert_txn_status(order_id, status)
    status_result = nil
    3.times do
      status_result = Veritrans.status(order_id)
      break if status_result.transaction_status == status
      sleep 0.3
    end
    status_result.transaction_status.should == status
  end

end