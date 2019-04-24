class AddCompanyRefToOffice < ActiveRecord::Migration[5.2]
  def change
    add_reference :offices, :company, foreign_key: true
  end
end
