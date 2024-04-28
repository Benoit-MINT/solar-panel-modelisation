class AddProfitToPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    add_column :photovoltaics, :profit, :float
  end
end
