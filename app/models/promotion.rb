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

class Promotion < ApplicationRecord

  begin :relationships
    belongs_to :office
    has_many :transaction_outputs
  end

  begin :validations
    validates :office_id, :title, :totalRewards, :pointsRequired, :terms, :startAt, :endAt, presence: true
  end
end
