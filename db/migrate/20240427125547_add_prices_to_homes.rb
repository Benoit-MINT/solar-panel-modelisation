class AddPricesToHomes < ActiveRecord::Migration[7.1]
  def change
    add_column :homes, :buy_price_electricity, :float
    add_column :homes, :sale_price_electricity, :float
  end
end
