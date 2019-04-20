# == Schema Information
#
# Table name: categories
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  points_per_dollar :integer          default(1)
#

FactoryBot.define do
  factory :category do
    
  end
end