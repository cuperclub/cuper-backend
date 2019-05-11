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

FactoryBot.define do
  factory :company do
    category
    ruc { "123123123" }
    economic_activity { "Sea food" }
    business_name { "Rumberitos" }
    legal_representative { "Perico de los Palotes" }
  end
end
