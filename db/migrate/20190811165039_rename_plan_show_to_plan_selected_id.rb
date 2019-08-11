class RenamePlanShowToPlanSelectedId < ActiveRecord::Migration[5.2]
  def change
    rename_column :app_settings, :show_plan, :plan_selected_id
  end
end
