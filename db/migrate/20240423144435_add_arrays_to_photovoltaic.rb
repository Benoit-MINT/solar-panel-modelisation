class AddArraysToPhotovoltaic < ActiveRecord::Migration[7.1]
  def change
    add_column :photovoltaics, :ratio_months, :integer, array: true, default: []
    add_column :photovoltaics, :production_months, :integer, array: true, default: []
  end
end
