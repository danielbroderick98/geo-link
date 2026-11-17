require "application_system_test_case"

class CountryTimelineSystemTest < ApplicationSystemTestCase
  test "visitors can open a treaty and an event from a country timeline" do
    country = countries(:one)
    treaty = treaties(:one)
    event = geopolitical_events(:one)

    visit user_country_path(country)
    # Scope the click to the timeline because the page has other navigation links.
    within "#country-timeline" do
      click_link treaty.name, href: user_treaty_path(treaty)
    end
    assert_current_path user_treaty_path(treaty)

    visit user_country_path(country)
    within "#country-timeline" do
      click_link event.title, href: user_geopolitical_event_path(event)
    end
    assert_current_path user_geopolitical_event_path(event)
  end
end
