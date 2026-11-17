class Treaty < ApplicationRecord
  # Delete the participant links when this treaty is deleted.
  # The countries themselves are kept.
  has_many :treaty_participants, dependent: :destroy

  # Access participating countries using treaty.countries.
  has_many :countries, through: :treaty_participants

  # A treaty can be saved before its optional signing date and description are known.
  validates :name, presence: true
end
