# == Schema Information
#
# Table name: plans
#
#  id          :bigint(8)        not null, primary key
#  price       :float            default(0.0)
#  name        :string
#  information :string
#  days        :integer          default(1)
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Plan < ApplicationRecord
  begin :relationships
    has_many :plan_companies
  end
end
