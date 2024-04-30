class DeleteRatioInPhotovoltaics < ActiveRecord::Migration[7.1]
  def change
    remove_column :photovoltaics, :ratio_months
  end
end
