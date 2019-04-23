class AddCategoryRefToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_reference :companies, :category, foreign_key: true
  end
end
