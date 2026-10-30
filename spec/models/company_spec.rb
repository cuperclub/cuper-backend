# == Schema Information
#
# Table name: companies
#
#  id                   :bigint(8)        not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  ruc                  :string
#  economic_activity    :string
#  contributor_type     :string
#  legal_representative :string
#  business_name        :string
#  logo                 :string
#  slogan               :string
#  active               :boolean          default(FALSE)
#  category_id          :bigint(8)
#

require 'rails_helper'

RSpec.describe Company, type: :model do
  it "requires its registration identity and category fields" do
    company = build(:company,
      ruc: nil,
      business_name: nil,
      legal_representative: nil,
      category: nil)

    expect(company).not_to be_valid
    expect(company.errors.attribute_names).to include(:ruc, :business_name, :legal_representative, :category)
  end

  it "requires a unique RUC" do
    existing_company = create(:company)
    duplicate = build(:company, ruc: existing_company.ruc)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:ruc]).to be_present
  end
end
