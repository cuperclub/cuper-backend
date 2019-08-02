class CreatePlanCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_companies do |t|
      t.references :plan, index: true, null: false
      t.references :company, index: true, null: false
      t.timestamps
    end
  end
end
