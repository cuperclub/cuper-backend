# == Schema Information
#
# Table name: transaction_outputs
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  points         :float
#  invoice_number :string
#  promotion_id   :bigint(8)
#  employee_id    :bigint(8)
#  user_id        :bigint(8)
#

class TransactionOutput < ApplicationRecord
  begin :relationships
    belongs_to :promotion
    belongs_to :employee
    belongs_to :user
  end

  begin :validations
    validate :user_has_enough_points
    validate :promotion_has_enough_rewards
    validates :points, numericality: { greater_than: 0 }
  end

  begin :callbacks
    after_create :update_user_points
    after_create :update_promotion
  end


  def update_user_points
    user.points = user.points - points
    user.save
  end

  def update_promotion
    if !promotion.unlimited
      promotion.total_rewards = promotion.total_rewards - 1
      promotion.save
    end
  end


  def user_has_enough_points
    if user && user.points - points < 0
      errors.add(
        :points,
        I18n.t("activerecord.errors.models.transaction_output.not_enough_points")
      )
    end
  end

  def promotion_has_enough_rewards
    if promotion && !promotion.unlimited && promotion.total_rewards - 1 != 0
      errors.add(
        :points,
        I18n.t("activerecord.errors.models.transaction_output.not_enough_rewards")
      )
    end
  end
end
