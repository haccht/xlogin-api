class CreateDrivers < ActiveRecord::Migration[6.1]
  def change
    create_table :drivers do |t|
      t.string :name, null: false
      t.text :template
      t.integer :size, default: 1
      t.integer :idle, default: 60

      t.timestamps
    end
  end
end
