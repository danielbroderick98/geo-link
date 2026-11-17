require "application_system_test_case"

class CountriesTest < ApplicationSystemTestCase
  test "shows saved countries" do
    admin = User.create!(name: "Browser Admin", email: "browser-admin@example.com",
      password: "GeoLink-test-password", role: "admin")
    # Sign in through the browser before opening the protected management page.
    visit admin_login_path
    fill_in "Email address", with: admin.email
    fill_in "Password", with: "GeoLink-test-password"
    click_button "Sign in"
    click_link "Manage countries"

    assert_selector "h1", text: "Manage countries"
    assert_text countries(:one).name
    assert_link "Edit", href: edit_admin_country_path(countries(:one))
  end
end
