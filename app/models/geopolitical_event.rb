class GeopoliticalEvent < ApplicationRecord
    # Require the main event details before saving.
    # The end date is optional because an event may still be ongoing.
    validates :title, :event_type, :started_on, :description, presence: true

    # Check that the end date does not come before the start date.
    validate :ended_on_cannot_precede_started_on

    # Remove the links when an event is deleted.
    has_many :event_countries, dependent: :destroy

    # Access all countries involved in this event.
    has_many :countries, through: :event_countries

    # Treat an event without an end date as ongoing.
    def ongoing?
        ended_on.nil?
    end

    private

    # Add a validation error if the event ends before it starts.
    def ended_on_cannot_precede_started_on
        # Only compare dates when both have been provided.
        return if started_on.blank? || ended_on.blank?

    if ended_on < started_on
      errors.add(:ended_on, "cannot be before the start date")
    end
  end
end
