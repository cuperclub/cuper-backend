# == Schema Information
#
# Table name: offices
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  email      :string
#  address    :string
#  active     :boolean          default(FALSE)
#  company_id :bigint(8)
#  lat        :float
#  long       :float
#  phone      :string
#

FactoryBot.define do
  factory :office do
    company
    name { "Sucursal 1" }
    address { "Corner 1" }
  end
end
