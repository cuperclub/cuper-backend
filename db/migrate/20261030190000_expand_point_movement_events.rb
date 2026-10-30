class ExpandPointMovementEvents < ActiveRecord::Migration[5.2]
  def up
    add_column :point_movements, :reference_key, :string
    add_column :point_movements, :reason, :string
    add_reference :point_movements, :reversal_of, foreign_key: { to_table: :point_movements }, index: false

    add_index :point_movements, [:user_id, :reference_key], unique: true,
      where: "reference_key IS NOT NULL",
      name: "index_point_movements_on_user_and_reference_key"
    add_index :point_movements, :reversal_of_id, unique: true

    remove_check_constraint :point_movements, name: "point_movements_valid_kind"
    remove_check_constraint :point_movements, name: "point_movements_kind_matches_points"

    add_check_constraint :point_movements,
      "(kind = 'accrual' AND transaction_input_id IS NOT NULL AND transaction_output_id IS NULL) OR (kind = 'redemption' AND transaction_output_id IS NOT NULL AND transaction_input_id IS NULL) OR (kind NOT IN ('accrual', 'redemption') AND transaction_input_id IS NULL AND transaction_output_id IS NULL)",
      name: "point_movements_valid_source"
    add_check_constraint :point_movements,
      "kind IN ('accrual', 'redemption', 'expiry', 'adjustment', 'reversal', 'opening_balance', 'reconciliation')",
      name: "point_movements_valid_kind"
    add_check_constraint :point_movements,
      "(kind = 'accrual' AND points >= 0) OR (kind IN ('redemption', 'expiry') AND points < 0) OR (kind IN ('adjustment', 'reversal', 'reconciliation') AND points <> 0) OR (kind = 'opening_balance' AND points > 0)",
      name: "point_movements_kind_matches_points"
    add_check_constraint :point_movements,
      "(kind = 'reversal') = (reversal_of_id IS NOT NULL)",
      name: "point_movements_reversal_reference"
    add_check_constraint :point_movements,
      "kind IN ('accrual', 'redemption') OR (length(trim(reference_key)) > 0 AND length(trim(reason)) > 0)",
      name: "point_movements_manual_event_metadata"

    remove_check_constraint :point_movements, name: "point_movements_one_source"
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "Expanded point movement events are accounting history and must not be removed"
  end
end
