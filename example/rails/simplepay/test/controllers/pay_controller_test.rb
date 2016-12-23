require 'test_helper'

class PayControllerTest < ActionDispatch::IntegrationTest
  test "should get notify" do
    get pay_notify_url
    assert_response :success
  end

end
