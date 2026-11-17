module GeoLink
  module CountryTimeline
    # Give treaties and events the same fields so the view can display one list.
    Entry = Struct.new(:type, :record_id, :title, :date, :ongoing)

    # The caller supplies records belonging to the selected country.
    def self.build(treaties:, events:)
      treaty_entries = treaties.filter_map do |treaty|
        # A treaty needs a signing date to be placed on the timeline.
        next unless treaty.date_signed

        Entry.new(:treaty, treaty.id, treaty.name, treaty.date_signed, false)
      end

      # Reuse the event model's rule for deciding whether an event is ongoing.
      event_entries = events.map do |event|
        Entry.new(:event, event.id, event.title, event.started_on, event.ongoing?)
      end

      # Negating the day number puts recent dates first.
      # Type and ID keep entries on the same date in a consistent order.
      (treaty_entries + event_entries).sort_by do |entry|
        [ -entry.date.jd, entry.type, entry.record_id ]
      end
    end
  end
end
