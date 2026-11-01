require "test_helper"

class AdminLoginTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Administrator", email: "admin-login@example.com",
      password: "GeoLink-test-password", role: "admin")
  end

  test "visitors can browse public pages but cannot access admin pages" do
    get user_countries_path
    assert_response :success
    [ admin_countries_path, admin_geopolitical_events_path,
      admin_diplomatic_relationships_path, admin_treaties_path,
      admin_treaty_participants_path ].each do |path|
      get path
      assert_redirected_to admin_login_path
    end
  end

  test "direct write requests cannot bypass login" do
    [ [ :post, admin_countries_path ], [ :patch, admin_country_path(countries(:one)) ],
      [ :delete, admin_country_path(countries(:one)) ],
      [ :post, admin_geopolitical_events_path ],
      [ :post, admin_diplomatic_relationships_path ], [ :post, admin_treaties_path ],
      [ :post, admin_treaty_participants_path ] ].each do |verb, path|
      public_send(verb, path)
      assert_redirected_to admin_login_path
    end
    assert Country.exists?(countries(:one).id)
  end

  test "valid admin can sign in and logout removes access" do
    post admin_login_path, params: { email: " ADMIN-LOGIN@example.com ", password: "GeoLink-test-password" }
    assert_redirected_to admin_countries_path
    get admin_countries_path
    assert_response :success
    delete admin_logout_path
    assert_redirected_to root_path
    get admin_countries_path
    assert_redirected_to admin_login_path
  end

  test "wrong passwords and ordinary accounts cannot sign in" do
    [ [ @admin.email, "incorrect" ], [ users(:one).email, "GeoLink-test-password" ],
      [ "missing@example.com", "incorrect" ] ].each do |email, password|
      post admin_login_path, params: { email: email, password: password, role: "admin" }
      assert_response :unprocessable_entity
      assert_select "[role=alert]", text: "Invalid email or password."
      get admin_countries_path
      assert_redirected_to admin_login_path
    end
  end

  test "changing an admin role revokes access on the next request" do
    post admin_login_path, params: { email: @admin.email, password: "GeoLink-test-password" }
    @admin.update!(role: "user")
    get admin_countries_path
    assert_response :forbidden
  end
end
