require "application_system_test_case"

class CountriesTest < ApplicationSystemTestCase
  test "shows saved countries" do
    visit admin_countries_path

    assert_selector "h1", text: "Manage countries"
    assert_text countries(:one).name
    assert_link "Edit", href: edit_admin_country_path(countries(:one))
  end
end
