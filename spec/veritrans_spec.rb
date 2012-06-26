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
		client = Veritrans::Client.new #.greet('Alice').must_equal('hello, Alice')
		client.order_id     = "1234"
		client.session_id   = "3456"
		client.gross_amount = "10"
		client.commodity    = [
		  {"COMMODITY_ID" => "IDxx1", "COMMODITY_UNIT" => "10", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "Waterbotle", "COMMODITY_NAME2" => "Waterbottle in Indonesian"}
		]  	
		client 
  }
  

  it '.hash_generator' do
     client.send(:merchanthash).must_equal("d05d80ceb9c4a9c8e2aabaa1b69dd43888c0cb21ac508b039acffbe6116d3bd1d00bf9d6f6f14d782587bf78f0314d1035d42139ef081e7fb5098f7463395bea")
  end

  it '#getkeys' do
		Faraday.stub(:new,@faraday) do 
  		client.get_keys.must_equal({"TOKEN_MERCHANT"=>"LJZTMuUGVvOYAEa55AWAkGpTckjBbuP9LS0ICWJra2iZfygT6w", "TOKEN_BROWSER"=>"Dha7NVnwNnh8UvJBISujEA5sRckLLcIEWgnNEVGLa38DTzRYIS"})
	  end
  end
end