class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :message
      t.string :status, default: "pending"
      t.string :kind
      t.references :from_user
      t.references :to_user
      t.timestamps
    end
  end
end
