class CreateTreatyParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :treaty_participants do |t|
      t.references :treaty, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
