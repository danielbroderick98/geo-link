module Admin
class GeopoliticalEventsController < ApplicationController
    # Find the event before displaying or updating its edit form.
    before_action :set_geopolitical_event, only: [:edit, :update]

    # Display saved events and a blank form for adding an event.
    def index
    # Load events and their linked countries together.
        @geopolitical_events = GeopoliticalEvent
        .includes(:countries)
        .order(started_on: :desc)
        @geopolitical_event = GeopoliticalEvent.new
    end

    # Save a new event using the permitted form fields.
    def create
    @geopolitical_event = GeopoliticalEvent.new(geopolitical_event_params)

    if @geopolitical_event.save
        redirect_to admin_geopolitical_events_path,
            notice: "Geopolitical event added successfully."
    else
        # Reload the list and preserve the form's values and errors.
        # Load events and their linked countries together.
        @geopolitical_events = GeopoliticalEvent
        .includes(:countries)
        .order(started_on: :desc)
        render :index, status: :unprocessable_entity
    end
    end

    # Display the edit form for the selected event.
    def edit
    end

    # Save changes to an existing event.
    def update
    if @geopolitical_event.update(geopolitical_event_params)
        redirect_to admin_geopolitical_events_path,
            notice: "Geopolitical event updated successfully."
    else
        # Display validation errors without clearing the entered values.
        render :edit, status: :unprocessable_entity
    end
    end

    private

    # Find the event using the ID supplied in the URL.
    # Rails returns a 404 response if the event does not exist.
    def set_geopolitical_event
    @geopolitical_event = GeopoliticalEvent.find(params[:id])
    end

    # Only allow these fields to be submitted through the form.
    # Rails manages the ID and timestamps automatically.
    def geopolitical_event_params
    params.require(:geopolitical_event).permit(
        :title,
        :event_type,
        :started_on,
        :ended_on,
        :description,
        country_ids: []
    )
    end
end
end