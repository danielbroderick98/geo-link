class Treaty < ApplicationRecord
  # Delete the participant links when this treaty is deleted.
  # The countries themselves are kept.
  has_many :treaty_participants, dependent: :destroy

  # Access participating countries using treaty.countries.
  has_many :countries, through: :treaty_participants

  # A treaty can be saved before its optional signing date and description are known.
  validates :name, presence: true

  # Limit public searches and sorting to the fields shown in the treaty directory.
  def self.ransackable_attributes(auth_object = nil)
    %w[name status date_signed]
  end

  # Countries are displayed with treaties, but this form searches treaty fields only.
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
