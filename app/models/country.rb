class Country < ApplicationRecord
  REGIONS = [
    "Africa",
    "Asia",
    "Europe",
    "North America",
    "Oceania",
    "South America"
  ].freeze

  # Clean up surrounding spaces before checking or saving the values.
  normalizes :name, :region, :capital, :political_system,
  with: ->(value) { value.strip }

  validates :name, presence: true,
  uniqueness: { case_sensitive: false }

  validates :capital, :political_system, presence: true

  # Only accept a region offered by the form.
  validates :region, inclusion: { in: REGIONS }

  validates :population,
  numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # Both true and false are valid; a missing value is not.
  validates :active, inclusion: { in: [ true, false ] }

  # Delete this country's participant links if the country is deleted.
  # The treaties themselves are kept.
  has_many :treaty_participants, dependent: :destroy

  # Access this country's treaties using country.treaties.
  has_many :treaties, through: :treaty_participants
end
