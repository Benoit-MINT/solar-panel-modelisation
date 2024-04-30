class AddNbPannelToPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    add_column :photovoltaics, :panel_number, :integer
  end
end
