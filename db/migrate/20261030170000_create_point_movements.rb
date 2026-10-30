class CreatePointMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :point_movements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :transaction_input, foreign_key: true, index: false
      t.references :transaction_output, foreign_key: true, index: false
      t.bigint :points, null: false
      t.string :kind, null: false
      t.string :idempotency_key
      t.timestamps null: false
    end

    add_check_constraint :point_movements,
      "(transaction_input_id IS NOT NULL) <> (transaction_output_id IS NOT NULL)",
      name: "point_movements_one_source"
    add_check_constraint :point_movements,
      "kind IN ('accrual', 'redemption')",
      name: "point_movements_valid_kind"
    add_index :point_movements, :transaction_input_id, unique: true
    add_index :point_movements, :transaction_output_id, unique: true
    add_index :point_movements, [:user_id, :idempotency_key], unique: true,
      where: "idempotency_key IS NOT NULL",
      name: "index_point_movements_on_user_and_idempotency_key"
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "Point movement history is accounting data and must not be deleted"
  end
end
