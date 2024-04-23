class RemoveColums < ActiveRecord::Migration[7.1]
  def change
    remove_column :homes, :home_consumption
    remove_column :homes, :self_consumption
    remove_column :homes, :back_energy
    remove_column :photovoltaics, :ratio
    remove_column :photovoltaics, :production
  end
end
