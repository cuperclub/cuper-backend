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
    validate :employee_cannot_redeem_own_promotion
    validates :points, numericality: { greater_than: 0 }
  end

  begin :callbacks
    after_create :update_user_points
    after_create :update_promotion
  end

  def self.redeem(user:, employee:, promotion:, invoice_number:)
    output = new(
      user: user,
      employee: employee,
      promotion: promotion,
      points: promotion.points_required,
      invoice_number: invoice_number
    )

    saved = if user
      transaction do
        user.with_lock do
          promotion.with_lock { output.save }
        end
      end
    else
      output.save
    end

    [output, saved]
  end


  def update_user_points
    user.update!(points: (user.points || 0) - points)
  end

  def update_promotion
    if !promotion.unlimited
      promotion.total_rewards = promotion.total_rewards - 1
      promotion.save!
    end
  end


  def user_has_enough_points
    if user && (user.points || 0) - points < 0
      errors.add(
        :points,
        I18n.t("activerecord.errors.models.transaction_output.not_enough_points")
      )
    end
  end

  def promotion_has_enough_rewards
    if promotion && !promotion.unlimited && promotion.total_rewards <= 0
      errors.add(
        :points,
        I18n.t("activerecord.errors.models.transaction_output.not_enough_rewards")
      )
    end
  end

  def employee_cannot_redeem_own_promotion
    errors.add(:user, :invalid) if employee && user == employee.user
  end
end
