class CreateActions < ActiveRecord::Migration[5.2]
  def change
    create_table :actions do |t|
      t.string :request
      t.string :response
      t.references :vendor, foreign_key: true

      t.timestamps
    end
  end
end
