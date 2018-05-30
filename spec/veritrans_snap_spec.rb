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

  it "should create snap token" do
    response = Veritrans.create_snap_token(
      transaction_details: {
        order_id: generate_order_id,
        gross_amount: 30_000
      }
    )

    response.should be_a(Veritrans::SnapResult)
    response.success?.should be_truthy
    response.token.should be_present
    response.token.should == response.data[:token]
    response.inspect.should =~ /#<Veritrans::SnapResult:\d+ \^\^ status: 201 time: \d+ms \^\^ data: \{token: "[\da-f\-]+", redirect_url: ".+"\}>/
  end

  it "should create snap redirect_url" do
    response = Veritrans.create_snap_redirect_url(
      transaction_details: {
        order_id: generate_order_id,
        gross_amount: 30_000
      }
    )

    response.should be_a(Veritrans::SnapResult)
    response.success?.should be_truthy
    response.redirect_url.should be_present
    response.redirect_url.should == response.data[:redirect_url]
    response.inspect.should =~ /#<Veritrans::SnapResult:\d+ \^\^ status: 201 time: \d+ms \^\^ data: \{token: "[\da-f\-]+", redirect_url: ".+"\}>/
  end
end
