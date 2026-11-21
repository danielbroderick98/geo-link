class CreateTreaties < ActiveRecord::Migration[8.1]
  def change
    # Store the agreement details here. Participating countries use their own join table.
    create_table :treaties do |t|
      t.string :name
      t.date :date_signed
      t.string :status
      t.text :description

      t.timestamps
    end
  end
end
