require "application_system_test_case"

class TreatySearchSystemTest < ApplicationSystemTestCase
  test "visitors can combine treaty filters sort the results and clear the search" do
    # Use different dates and statuses so each control changes the visible results.
    Treaty.destroy_all
    older = Treaty.create!(name: "Trade accord", status: "Signed", date_signed: "2020-01-01")
    newer = Treaty.create!(name: "Trade framework", status: "Signed", date_signed: "2024-12-31")
    draft = Treaty.create!(name: "Trade proposal", status: "Draft", date_signed: "2023-04-10")

    visit user_treaties_path
    fill_in "Treaty name", with: "trade"
    select "Signed", from: "Treaty status"
    # Date objects let Capybara fill native date controls in the browser's format.
    fill_in "Signing date from", with: Date.new(2020, 1, 1)
    fill_in "Signing date until", with: Date.new(2024, 12, 31)
    select "Signing date (newest first)", from: "Sort by"
    click_button "Search"

    # Wait for the submitted form and check the order in the name column.
    assert_selector "tbody tr", count: 2
    assert_equal [ newer.name, older.name ], all("tbody th a").map(&:text)
    assert_no_selector "tbody th a", text: draft.name
    assert_selector "select#q_s option:checked", text: "Signing date (newest first)"

    # Keep a browser image for checking the layout of the expanded form.
    save_screenshot Rails.root.join("tmp/treaty-search.png")
    page.current_window.resize_to(390, 844)
    assert_no_horizontal_overflow = page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    assert assert_no_horizontal_overflow
    save_screenshot Rails.root.join("tmp/treaty-search-mobile.png")
    page.current_window.resize_to(1400, 1400)

    click_link "Clear search and filters"

    assert_selector "tbody tr", count: 3
    assert_field "Treaty name", with: ""
    assert_field "Signing date from", with: ""
    assert_field "Signing date until", with: ""
    assert_selector "select#q_status_eq option:checked", text: "All statuses"
    assert_selector "select#q_s option:checked", text: "Name (A–Z)"

    # Filtering still leaves the normal public detail links available.
    within "tbody" do
      click_link newer.name
    end
    assert_current_path user_treaty_path(newer)
  end
end
