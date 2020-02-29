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
#  start_date :datetime
#

FactoryBot.define do
  factory :plan_company do
    
  end
end
