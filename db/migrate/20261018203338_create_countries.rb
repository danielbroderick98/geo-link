class CreateCountries < ActiveRecord::Migration[8.1]
  def change
    create_table :countries do |t|
    # Require the main country details at database level.
    t.string :name, null: false
    t.string :region, null: false
    t.string :capital, null: false
    t.integer :population, null: false
    t.string :political_system, null: false

    # New countries are active unless explicitly marked inactive.
    t.boolean :active, null: false, default: true

    t.timestamps
    end

    # Prevent duplicate names regardless of capitalisation.
    add_index :countries, "LOWER(name)",
      unique: true,
      name: "index_countries_on_lower_name"

    # Prevent negative population values in the database.
    add_check_constraint :countries,
      "population >= 0",
      name: "countries_population_non_negative"
  end
end
