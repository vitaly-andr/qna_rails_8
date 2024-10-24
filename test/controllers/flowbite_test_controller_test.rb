require "test_helper"

class FlowbiteTestControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get flowbite_test_index_url
    assert_response :success
  end
end
