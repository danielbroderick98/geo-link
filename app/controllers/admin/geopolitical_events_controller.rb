module Admin
  class GeopoliticalEventsController < ApplicationController
    # Find the saved event before editing or updating it.
    before_action :set_geopolitical_event, only: [:edit, :update]

    def index
      load_events

      # Prepare a blank form without selected countries.
      @geopolitical_event = GeopoliticalEvent.new
      @selected_country_ids = []
    end

    def create
      # Assign ordinary fields separately from country associations.
      # Country choices remain unsaved while using the picker.
      @geopolitical_event = GeopoliticalEvent.new(event_attributes)
      prepare_country_selection

      if country_picker_request?
        # Redisplay the form without creating an event.
        load_events
        render :index
      else
        save_event(:index, "Geopolitical event added successfully.")
      end
    end

    def edit
      # Show the countries already linked to this event.
      @selected_country_ids = @geopolitical_event.country_ids.map(&:to_s)
    end

    def update
      # Preserve submitted fields without saving them yet.
      @geopolitical_event.assign_attributes(event_attributes)
      prepare_country_selection

      if country_picker_request?
        # Redisplay the edit form without changing saved associations.
        render :edit
      else
        save_event(:edit, "Geopolitical event updated successfully.")
      end
    end

    private

    def load_events
      # Load linked countries together with the events.
      @geopolitical_events = GeopoliticalEvent
        .includes(:countries)
        .order(started_on: :desc)
    end

    def set_geopolitical_event
      # Return a 404 response if the event does not exist.
      @geopolitical_event = GeopoliticalEvent.find(params[:id])
    end

    def geopolitical_event_params
      # Permit the event fields and the selected country IDs.
      params.require(:geopolitical_event).permit(
        :title,
        :event_type,
        :started_on,
        :ended_on,
        :description,
        country_ids: []
      )
    end

    def event_attributes
      # Avoid assigning country_ids until the user saves the event.
      # Assigning associations on an existing record can write to the database.
      geopolitical_event_params.except(:country_ids)
    end

    def country_picker_request?
      # These buttons update the form rather than save the event.
      params[:country_action] == "add" || params[:remove_country].present?
    end

    def prepare_country_selection
      # Read the hidden fields containing the current unsaved selection.
      ids = Array(geopolitical_event_params[:country_ids])
        .reject(&:blank?)
        .map(&:to_s)

      if params[:country_action] == "add"
        # Add the country chosen in the dropdown.
        ids << params[:selected_country_id].to_s
      elsif params[:remove_country].present?
        # Remove only the selected country.
        ids.delete(params[:remove_country].to_s)
      end

      # Keep valid country IDs and prevent duplicate selections.
      @selected_country_ids = Country
        .where(id: ids.reject(&:blank?).uniq)
        .pluck(:id)
        .map(&:to_s)
    end

    def save_event(template, success_message)
      # Save event details and country links together.
      # If validation fails, roll back changes to existing associations.
      GeopoliticalEvent.transaction do
        @geopolitical_event.country_ids = @selected_country_ids
        @geopolitical_event.save!
      end

      redirect_to admin_geopolitical_events_path,
                  notice: success_message,
                  status: :see_other
    rescue ActiveRecord::RecordInvalid
      # Preserve form fields, selected countries, and validation errors.
      load_events if template == :index
      render template, status: :unprocessable_entity
    end
  end
end