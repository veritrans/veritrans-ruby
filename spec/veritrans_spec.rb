require 'spec_helper'
require 'veritrans'

describe Veritrans::Client,Faraday::Connection do
	before do
		@conn     = MiniTest::Mock.new
		@conn.expect(:env, {
			url:  "http://test", 
			body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n\r\n\r\n\r\nTOKEN_MERCHANT=LJZTMuUGVvOYAEa55AWAkGpTckjBbuP9LS0ICWJra2iZfygT6w\r\nTOKEN_BROWSER=Dha7NVnwNnh8UvJBISujEA5sRckLLcIEWgnNEVGLa38DTzRYIS\r\n"
		})

	  @faraday = MiniTest::Mock.new
	  @faraday.expect(:post, @conn)
	end

  let(:client) {
		client = Veritrans::Client.new 
		client.order_id     = "1234"
		client.session_id   = "3456"
		client.gross_amount = "10"
		client.commodity    = [
		  {"COMMODITY_ID" => "IDxx1", "COMMODITY_UNIT" => "10", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "Waterbotle", "COMMODITY_NAME2" => "Waterbottle in Indonesian"}
		]  	
		client 
  }
  

  it '.hash_generator' do
     client.send(:merchanthash).must_equal("13bbc9e66f2a698e5a258961457ab59e7a514ef1355fba8cc5fd4156405725bc8a31328470e21dca9dc195bb3babdcf6019d5fdef349c6b317676a59dea980a6")
  end

  it '#getkeys' do
		Faraday.stub(:new,@faraday) do 
  		client.get_keys.must_equal({"TOKEN_MERCHANT"=>"LJZTMuUGVvOYAEa55AWAkGpTckjBbuP9LS0ICWJra2iZfygT6w", "TOKEN_BROWSER"=>"Dha7NVnwNnh8UvJBISujEA5sRckLLcIEWgnNEVGLa38DTzRYIS"})
	  end
  end
end