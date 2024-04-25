class ChangePowerToPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    change_column :photovoltaics, :power, :float
  end
end
