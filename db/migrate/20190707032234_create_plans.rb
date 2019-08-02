class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.float :price, default: 0
      t.string :name
      t.string :information
      t.integer :days, default: 1
      t.boolean :active, default: true
      t.string :information
      t.timestamps
    end
  end
end
