class AddNameToHomes < ActiveRecord::Migration[7.1]
  def change
    add_column :homes, :name, :string
  end
end
