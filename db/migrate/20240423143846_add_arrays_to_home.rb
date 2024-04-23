class AddArraysToHome < ActiveRecord::Migration[7.1]
  def change
    add_column :homes, :home_consumption_months, :integer, array: true, default: []
    add_column :homes, :self_consumption_months, :integer, array: true, default: []
    add_column :homes, :back_energy_months, :integer, array: true, default: []
  end
end
