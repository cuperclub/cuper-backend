class AddFieldsToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :role, :string
    add_column :employees, :active, :boolean, default: false
  end
end
