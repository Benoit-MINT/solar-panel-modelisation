class AddEconomicsToPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    add_column :photovoltaics, :investment, :float
    add_column :photovoltaics, :roi, :float
    add_column :photovoltaics, :sale_electricity_months, :float, array: true, default: []
    add_column :photovoltaics, :self_electricity_months, :float, array: true, default: []
  end
end
