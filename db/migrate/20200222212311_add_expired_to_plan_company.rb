class AddExpiredToPlanCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_companies, :expired, :boolean, default: false
  end
end
