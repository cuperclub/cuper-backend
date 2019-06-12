class AddPhoneColumnToOffice < ActiveRecord::Migration[5.2]
  def change
    add_column :offices, :phone, :string
  end
end
