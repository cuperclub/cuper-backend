class CreateAppSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :app_settings do |t|
      t.integer :show_plan
      t.integer :points_by_register
      t.timestamps
    end
  end
end
