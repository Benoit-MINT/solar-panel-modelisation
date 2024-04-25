class ChangeSelfAndBackToPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    remove_column :homes, :self_consumption_months
    remove_column :homes, :back_energy_months
    add_column :photovoltaics, :self_consumption_months, :integer, array: true, default: []
    add_column :photovoltaics, :back_energy_months, :integer, array: true, default: []
  end
end
