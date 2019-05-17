class AddStatusAndRemoveActiveToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :status, :string, default: :pending
    remove_column :employees, :active, :boolean
  end
end
