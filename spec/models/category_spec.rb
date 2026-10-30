# == Schema Information
#
# Table name: categories
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  points_per_dollar :integer          default(1)
#  active            :boolean          default(TRUE)
#

require 'rails_helper'

RSpec.describe Category, type: :model do
  it "requires a name and points-per-dollar value" do
    category = build(:category, name: nil, points_per_dollar: nil)

    expect(category).not_to be_valid
    expect(category.errors.attribute_names).to include(:name, :points_per_dollar)
  end
end
