class AddStartDateToPlanCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_companies, :start_date, :datetime
  end
end
