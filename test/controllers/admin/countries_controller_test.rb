require "test_helper"

class Admin::CountriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    admin = User.create!(name: "Controller Admin", email: "controller-admin@example.com",
      password: "GeoLink-test-password", role: "admin")
    post admin_login_path, params: { email: admin.email, password: "GeoLink-test-password" }
    get admin_countries_url
    assert_response :success
  end
end
