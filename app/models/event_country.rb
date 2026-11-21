class EventCountry < ApplicationRecord
  # Each record links one geopolitical event to one country.
  belongs_to :geopolitical_event
  belongs_to :country
  # Remove the links when a country is deleted.
  has_many :event_countries, dependent: :destroy

  # Access all geopolitical events involving this country.
  has_many :geopolitical_events, through: :event_countries

  # Prevent duplicate country links within the same event.
  validates :country_id, uniqueness: { scope: :geopolitical_event_id }
end
