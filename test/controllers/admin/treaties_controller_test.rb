require "test_helper"

class Admin::TreatiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = User.create!(name: "Test Admin", email: "route-admin@example.com",
      password: "GeoLink-test-password", role: "admin")
    # Both route checks need an authenticated admin session.
    post admin_login_path, params: { email: admin.email, password: "GeoLink-test-password" }
  end
  test "should get index" do
    get admin_treaties_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_treaty_url
    # The add form is on the management page, so the new route returns there.
    assert_redirected_to admin_treaties_url
  end
end
