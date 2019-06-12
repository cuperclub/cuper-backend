class AddLatLongColumnsToOffice < ActiveRecord::Migration[5.2]
  def change
    add_column :offices, :lat, :float
    add_column :offices, :long, :float
  end
end
