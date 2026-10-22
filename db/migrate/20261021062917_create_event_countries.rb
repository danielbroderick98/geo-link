class CreateEventCountries < ActiveRecord::Migration[8.1]
  def change
    create_table :event_countries do |t|
      t.references :geopolitical_event, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
    # Prevent the same country being linked to the same event twice.
    add_index :event_countries,
      [:geopolitical_event_id, :country_id],
      unique: true
  end
end
