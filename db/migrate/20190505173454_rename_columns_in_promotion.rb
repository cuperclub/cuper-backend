class RenameColumnsInPromotion < ActiveRecord::Migration[5.2]
  def change
    rename_column :promotions, :totalRewards, :total_rewards
    rename_column :promotions, :pointsRequired, :points_required
    rename_column :promotions, :startAt, :start_at
    rename_column :promotions, :endAt, :end_at
  end
end
