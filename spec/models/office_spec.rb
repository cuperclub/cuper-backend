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

require 'rails_helper'

RSpec.describe Office, type: :model do
  it "requires a company, name, and address" do
    office = build(:office, company: nil, name: nil, address: nil)

    expect(office).not_to be_valid
    expect(office.errors.attribute_names).to include(:company, :name, :address)
  end
end
