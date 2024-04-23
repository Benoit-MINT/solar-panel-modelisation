class CreatePhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    create_table :photovoltaics do |t|
      t.integer :power
      t.integer :ratio
      t.integer :production
      t.references :home, null: false, foreign_key: true

      t.timestamps
    end
  end
end
