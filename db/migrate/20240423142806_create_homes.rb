class CreateHomes < ActiveRecord::Migration[7.1]
  def change
    create_table :homes do |t|
      t.string :address
      t.float :longitude
      t.float :latitude
      t.integer :home_consumption
      t.integer :self_consumption
      t.integer :back_energy

      t.timestamps
    end
  end
end
