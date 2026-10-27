class CreateTreaties < ActiveRecord::Migration[8.1]
  def change
    create_table :treaty_participants do |t|
      # Link this participant record to an existing treaty.
      t.references :treaty, null: false, foreign_key: true

      # Link this participant record to an existing country.
      t.references :country, null: false, foreign_key: true

      # Record when this entry was created and last updated.
      t.timestamps
      end

      # Prevent the same country from being added to the same treaty twice.
      add_index :treaty_participants,
        [:treaty_id, :country_id],
        unique: true
    end
  end
end
