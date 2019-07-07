# == Schema Information
#
# Table name: plans
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  company_id :bigint(8)        not null
#  price      :float            default(0.0)
#  name       :string
#  days       :integer          default(1)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :plan do
    
  end
end
