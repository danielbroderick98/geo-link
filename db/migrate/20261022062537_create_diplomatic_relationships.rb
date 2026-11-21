class CreateDiplomaticRelationships < ActiveRecord::Migration[8.1]
  def change
    create_table :diplomatic_relationships do |t|
      t.references :country_1, null: false,
        foreign_key: { to_table: :countries }
      t.references :country_2, null: false,
        foreign_key: { to_table: :countries }
      t.string :relationship_type, null: false

      t.timestamps
    end
  end
end
