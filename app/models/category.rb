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

class Category < ApplicationRecord

  begin :relationships
    has_many :companies
  end
end
