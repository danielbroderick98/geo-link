class TreatyParticipant < ApplicationRecord
  # Each participant record belongs to one treaty.
  belongs_to :treaty

  # Together, these foreign keys link a country to a treaty.
  belongs_to :country

  # Show a helpful validation error for duplicate participants.
  # The unique database index also enforces this rule.
  validates :country_id,
    uniqueness: {
      scope: :treaty_id,
      message: "is already a participant in this treaty"
    }
end
