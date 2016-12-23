describe Veritrans do
  include ActiveSupport::Testing::Stream

  before do
    stub_const("CONFIG", {})
    Veritrans.logger = Logger.new(STDOUT)
    Veritrans.file_logger = Logger.new(STDOUT)
    Veritrans.setup do
      config.load_yml "./example/sinatra/veritrans.yml#development"
    end
  end

  after do
    if Veritrans.events.listeners
      Veritrans.events.listeners.clear
    end
  end

  JSON_RESPONSE = '{
    "status_code": "200",
    "status_message": "Success, transaction found",
    "transaction_id": "b1cbcc66-5608-4af1-a3ed-0f152f9ed871",
    "order_id": "testing-0.2703-1415600236",
    "payment_type": "credit_card",
    "transaction_time": "2014-11-10 13:17:33",
    "transaction_status": "settlement",
    "gross_amount": "30000.00",
    "masked_card": "481111-1114",
    "fraud_status": "accept",
    "approval_code": "1415600254322",
    "bank": "bni"
  }'

  DOUBLE_ENCODED_JSON_RESPONSE = JSON.dump(JSON_RESPONSE)

  def stub_vt_status_response
    stub_request(:any, /.*veritrans.*/).to_return(lambda {|request|
      {status: 200, body: JSON_RESPONSE}
    })
  end

  it "should work with single encoded json" do
    Veritrans.events.subscribe('payment.success') do |payment|
      @payment = payment
    end

    stub_vt_status_response

    handler = Rack::MockRequest.new(Veritrans::Events.new)
    silence_stream(STDOUT) do
      handler.post("http://example.com/", input: JSON_RESPONSE)
    end

    @payment.order_id.should == "testing-0.2703-1415600236"
  end

  it "should work with double encoded json" do
    Veritrans.events.subscribe('payment.success') do |payment|
      @payment = payment
    end

    stub_vt_status_response

    handler = Rack::MockRequest.new(Veritrans::Events.new)
    silence_stream(STDOUT) do
      handler.post("http://example.com/", input: DOUBLE_ENCODED_JSON_RESPONSE)
    end

    @payment.order_id.should == "testing-0.2703-1415600236"
  end

end