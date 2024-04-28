class AddPriceConsumptionToHome < ActiveRecord::Migration[7.1]
  def change
    add_column :homes, :price_consumption_months, :float, array: true, default: []
  end
end
