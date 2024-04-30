class AddNameToPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    add_column :photovoltaics, :name, :string
  end
end
