require "test_helper"

class CountryTimelinePageTest < ActionDispatch::IntegrationTest
  test "the country profile shows only its linked treaties and events" do
    treaty = treaties(:one)
    event = geopolitical_events(:one)
    # Make the linked event ongoing so the rendered badge is checked too.
    event.update!(ended_on: nil)

    get user_country_path(countries(:one))

    assert_response :success
    assert_select "section#country-timeline" do
      # The treaty fixture is newer than the event fixture.
      assert_select "li", count: 2
      assert_select "li:first-child a[href=?]", user_treaty_path(treaty), text: treaty.name
      assert_select "li:last-child a[href=?]", user_geopolitical_event_path(event), text: event.title
      assert_select "li:last-child time[datetime=?]", event.started_on.iso8601
      assert_select "li:last-child .badge", text: "Ongoing"
      # The second set of fixtures belongs to another country.
      assert_select "a[href=?]", user_treaty_path(treaties(:two)), count: 0
      assert_select "a[href=?]", user_geopolitical_event_path(geopolitical_events(:two)), count: 0
    end
  end

  test "the country profile explains an empty timeline" do
    country = countries(:one)
    # Remove the links within this test to exercise the empty profile state.
    country.treaties.clear
    country.geopolitical_events.clear

    get user_country_path(country)

    assert_response :success
    assert_select "section#country-timeline p", text: "There are no timeline entries for this country yet."
  end
end
