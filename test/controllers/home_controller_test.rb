require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    user = users(:one)
    post session_url, params: { email_address: user.email_address, password: "password" }

    get home_index_url
    assert_response :success
  end
end
