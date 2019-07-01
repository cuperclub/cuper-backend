class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.references :user, index: true, null: false
      t.integer :current_company
      t.timestamps
    end
  end
end
