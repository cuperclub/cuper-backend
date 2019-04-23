class AddColumnsToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :name, :string
    add_column :categories, :points_per_dollar, :integer, default: 1
  end
end
