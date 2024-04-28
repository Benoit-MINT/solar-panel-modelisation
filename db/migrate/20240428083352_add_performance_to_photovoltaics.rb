class AddPerformanceToPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    add_column :photovoltaics, :annual_performance, :float
    add_column :photovoltaics, :global_performance, :float
  end
end
