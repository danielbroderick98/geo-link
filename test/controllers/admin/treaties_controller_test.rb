require "test_helper"

class Admin::TreatiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_treaties_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_treaties_new_url
    assert_response :success
  end
end
