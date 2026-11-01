# Display geopolitical events without allowing users to change them.
class User::GeopoliticalEventsController < ApplicationController
  def index
    # Preserve the search text for display in the form.
    @query = params[:query].to_s.strip

    # Only accept recognised status filters.
    # An empty status means all events.
    @status = params[:status].to_s
    @status = "" unless %w[ongoing ended].include?(@status)

    # Load countries alongside events to avoid a separate
    # country query for every row in the directory.
    # Show the most recently started events first.
    @geopolitical_events = GeopoliticalEvent
      .includes(:countries)
      .order(started_on: :desc, id: :desc)

    if @query.present?
      # Escape wildcard characters so the search treats them
      # as ordinary text.
      escaped_query = GeopoliticalEvent.sanitize_sql_like(
        @query.downcase
      )

      # Search event titles using a parameter placeholder.
      @geopolitical_events = @geopolitical_events.where(
        "LOWER(title) LIKE ?",
        "%#{escaped_query}%"
      )
    end

    # Follow the model's definition:
    # no end date means ongoing; an end date means ended.
    case @status
    when "ongoing"
      @geopolitical_events = @geopolitical_events.where(
        ended_on: nil
      )
    when "ended"
      @geopolitical_events = @geopolitical_events.where.not(
        ended_on: nil
      )
    end
  end

  def show
    # Load the selected event and its participating countries.
    # Rails returns a 404 response if the event does not exist.
    @geopolitical_event = GeopoliticalEvent
      .includes(:countries)
      .find(params[:id])
  end
end