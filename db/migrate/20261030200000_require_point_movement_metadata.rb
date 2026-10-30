class RequirePointMovementMetadata < ActiveRecord::Migration[5.2]
  def up
    remove_check_constraint :point_movements, name: "point_movements_manual_event_metadata"
    add_check_constraint :point_movements,
      "kind IN ('accrual', 'redemption') OR (COALESCE(length(trim(reference_key)), 0) > 0 AND COALESCE(length(trim(reason)), 0) > 0)",
      name: "point_movements_manual_event_metadata"
  end

  def down
    remove_check_constraint :point_movements, name: "point_movements_manual_event_metadata"
    add_check_constraint :point_movements,
      "kind IN ('accrual', 'redemption') OR (length(trim(reference_key)) > 0 AND length(trim(reason)) > 0)",
      name: "point_movements_manual_event_metadata"
  end
end
