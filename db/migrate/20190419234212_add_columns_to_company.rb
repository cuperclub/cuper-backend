class AddColumnsToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :ruc, :string
    add_column :companies, :economic_activity, :string
    add_column :companies, :contributor_type, :string
    add_column :companies, :legal_representative, :string
    add_column :companies, :business_name, :string
    add_column :companies, :logo, :string
    add_column :companies, :slogan, :string
    add_column :companies, :active, :boolean, default: false
  end
end
