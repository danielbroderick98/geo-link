class DiplomaticRelationship < ApplicationRecord
  # Link both country fields to records in the Country model.
  belongs_to :country_1, class_name: "Country"
  belongs_to :country_2, class_name: "Country"

  # Require a relationship type before saving.
  validates :relationship_type, presence: true

  # Run our custom check to prevent a country relating to itself.
  validate :different_countries

  private

  # Keep this validation method internal to the model.
  def different_countries
    # Check that Country 1 is selected and both country IDs match.
    if country_1_id.present? && country_1_id == country_2_id
      # Add an error to Country 2, preventing the record from saving.
      errors.add(:country_2, "must be different from Country 1")
    end
  end
end