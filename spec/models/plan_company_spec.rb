# == Schema Information
#
# Table name: plan_companies
#
#  id         :bigint(8)        not null, primary key
#  plan_id    :bigint(8)        not null
#  company_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expired    :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe PlanCompany, type: :model do
  it "requires both a plan and a company" do
    subscription = build(:plan_company, plan: nil, company: nil)

    expect(subscription).not_to be_valid
    expect(subscription.errors.attribute_names).to include(:plan, :company)
  end
end
