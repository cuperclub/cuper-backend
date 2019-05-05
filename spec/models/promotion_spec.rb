# == Schema Information
#
# Table name: promotions
#
#  id              :bigint(8)        not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  title           :string
#  description     :string
#  terms           :string
#  image           :string
#  background      :string
#  total_rewards   :integer          default(0)
#  points_required :integer          default(0)
#  start_at        :datetime
#  end_at          :datetime
#  unlimited       :boolean          default(FALSE)
#  office_id       :bigint(8)
#

require 'rails_helper'

RSpec.describe Promotion, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
