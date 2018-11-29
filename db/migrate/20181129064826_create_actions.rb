class CreateActions < ActiveRecord::Migration[5.2]
  def change
    create_table :actions do |t|
      t.text :request
      t.text :response
      t.references :vendor, foreign_key: true

      t.timestamps
    end
  end
end
