class ChangeTypeInPhotovoltaic < ActiveRecord::Migration[7.1]
  def change
    change_column :photovoltaics, :production_months, :float, array: true, default: []
    change_column :photovoltaics, :self_consumption_months, :float, array: true, default: []
    change_column :photovoltaics, :back_energy_months, :float, array: true, default: []
  end
end
