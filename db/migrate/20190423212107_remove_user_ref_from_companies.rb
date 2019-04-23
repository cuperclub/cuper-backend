class RemoveUserRefFromCompanies < ActiveRecord::Migration[5.2]
  def change
    remove_reference :companies, :user, foreign_key: true
  end
end
