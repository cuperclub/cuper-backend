# == Schema Information
#
# Table name: promotions
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  title          :string
#  description    :string
#  terms          :string
#  image          :string
#  background     :string
#  totalRewards   :integer          default(0)
#  pointsRequired :integer          default(0)
#  startAt        :datetime
#  endAt          :datetime
#  unlimited      :boolean          default(FALSE)
#  office_id      :bigint(8)
#

require 'rails_helper'

RSpec.describe Promotion, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
