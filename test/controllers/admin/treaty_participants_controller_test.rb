require "test_helper"

class Admin::TreatyParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = User.create!(name: "Test Admin", email: "route-admin@example.com",
      password: "GeoLink-test-password", role: "admin")
    post admin_login_path, params: { email: admin.email, password: "GeoLink-test-password" }
  end
  test "should get index" do
    get admin_treaty_participants_url
    assert_response :success
  end
end
