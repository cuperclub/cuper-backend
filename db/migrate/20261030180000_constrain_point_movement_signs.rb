class ConstrainPointMovementSigns < ActiveRecord::Migration[5.2]
  def change
    add_check_constraint :point_movements,
      "(kind = 'accrual' AND points >= 0) OR (kind = 'redemption' AND points < 0)",
      name: "point_movements_kind_matches_points"
  end
end
