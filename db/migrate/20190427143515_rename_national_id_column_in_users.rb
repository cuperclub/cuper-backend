class RenameNationalIdColumnInUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :nationalId, :national_id
  end
end
