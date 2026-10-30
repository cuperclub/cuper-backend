# == Schema Information
#
# Table name: plans
#
#  id          :bigint(8)        not null, primary key
#  price       :bigint(8)        default(0)
#  name        :string
#  information :string
#  days        :integer          default(1)
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Plan, type: :model do
  it "rejects fractional or unsafe prices instead of truncating them" do
    plan = build(:plan, price: "29.5")

    expect(plan).not_to be_valid
    expect(plan.errors[:price]).to be_present
  end

  it "accepts whole-unit prices" do
    expect(build(:plan, price: 29)).to be_valid
  end
end
