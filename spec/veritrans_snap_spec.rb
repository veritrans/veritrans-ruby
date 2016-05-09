describe Veritrans::Config do

  before do
    hide_const("Rails")
    Veritrans.logger = Logger.new("/dev/null")
    Veritrans.setup do
      config.load_config "./spec/configs/real_key.yml"
    end

    VCR.configure do |c|
      c.allow_http_connections_when_no_cassette = true
    end
  end

  after do
    VCR.configure do |c|
      c.allow_http_connections_when_no_cassette = false
    end
  end

  def generate_order_id
    "testing-#{rand.round(4)}-#{Time.now.to_i}"
  end

  it "should create widget token" do
    response = Veritrans.create_widget_token(
      transaction_details: {
        order_id: generate_order_id,
        gross_amount: 30_000
      }
    )

    response.should be_a(Veritrans::SnapResult)
    response.success?.should be_truthy
    response.token_id.should be_present
    response.token_id.should == response.data[:token_id]
    response.inspect.should =~ /#<Veritrans::SnapResult:\d+ \^\^ http_status: 200 time: \d+ms \^\^ data: \{token_id: "[\da-f\-]+"\}>/
  end
end