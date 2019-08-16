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

require 'rails_helper'

RSpec.describe Plan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
