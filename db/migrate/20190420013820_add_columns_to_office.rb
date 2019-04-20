class AddColumnsToOffice < ActiveRecord::Migration[5.2]
  def change
    add_column :offices, :name, :string
    add_column :offices, :email, :string
    add_column :offices, :address, :string
    add_column :offices, :active, :boolean, default: false
  end
end
