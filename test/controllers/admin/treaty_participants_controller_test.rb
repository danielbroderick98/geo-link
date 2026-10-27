require "test_helper"

class Admin::TreatyParticipantsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_treaty_participants_index_url
    assert_response :success
  end
end
