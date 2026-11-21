require "date"
require "minitest/autorun"
require_relative "../../../lib/geo_link/country_timeline"

class CountryTimelineTest < Minitest::Test
  # Small stand-ins let us test the library without loading Rails or the database.
  Treaty = Struct.new(:id, :name, :date_signed)
  Event = Struct.new(:id, :title, :started_on, :ended_on) do
    def ongoing?
      ended_on.nil?
    end
  end

  def test_lists_treaties_and_events_newest_first
    # Supply the older treaty first to check that the library sorts the records.
    treaty = Treaty.new(1, "Trade agreement", Date.new(2024, 3, 12))
    event = Event.new(2, "Regional summit", Date.new(2025, 6, 8), Date.new(2025, 6, 9))

    entries = GeoLink::CountryTimeline.build(treaties: [ treaty ], events: [ event ])

    assert_equal [
      [ :event, 2, "Regional summit", event.started_on ],
      [ :treaty, 1, "Trade agreement", treaty.date_signed ]
    ], entries.map { |entry| [ entry.type, entry.record_id, entry.title, entry.date ] }
    # The summit has an end date, so it should be shown as finished.
    refute entries.first.ongoing
  end

  def test_marks_an_event_without_an_end_date_as_ongoing
    # Leaving the end date empty matches the model's ongoing-event rule.
    event = Event.new(1, "Peace talks", Date.new(2025, 6, 8))

    entries = GeoLink::CountryTimeline.build(treaties: [], events: [ event ])

    assert entries.first.ongoing
  end

  def test_omits_an_undated_treaty
    # Signing dates are optional on saved treaties.
    treaty = Treaty.new(1, "Trade agreement")

    assert_empty GeoLink::CountryTimeline.build(treaties: [ treaty ], events: [])
  end

  def test_returns_no_entries_when_no_records_are_linked
    # A country can exist before any treaties or events have been linked to it.
    assert_empty GeoLink::CountryTimeline.build(treaties: [], events: [])
  end

  def test_orders_same_day_entries_by_type_and_id
    date = Date.new(2025, 6, 8)
    treaty = Treaty.new(1, "Trade agreement", date)
    # Reverse the event IDs to check the tie-break when all dates match.
    events = [
      Event.new(3, "Peace talks", date),
      Event.new(2, "Regional summit", date)
    ]

    entries = GeoLink::CountryTimeline.build(treaties: [ treaty ], events: events)

    assert_equal [ 2, 3, 1 ], entries.map(&:record_id)
  end
end
