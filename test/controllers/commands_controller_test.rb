require "test_helper"

class CommandsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get commands_show_url
    assert_response :success
  end
end
