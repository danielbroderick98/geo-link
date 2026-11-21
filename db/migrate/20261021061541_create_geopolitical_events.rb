class CreateGeopoliticalEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :geopolitical_events do |t|
      t.string :title
      t.string :event_type
      t.date :started_on
      t.date :ended_on
      t.text :description

      t.timestamps
    end
  end
end
