class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.references :user, index: true, null: false
      t.references :company, index: true, null: false
      t.float :price, default: 0
      t.string :name
      t.integer :days, default: 1
      t.timestamps
    end
  end
end
