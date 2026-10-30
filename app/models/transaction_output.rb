# == Schema Information
#
# Table name: transaction_outputs
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  points         :bigint(8)
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
    has_one :point_movement
  end

  begin :validations
    validate :user_has_enough_points
    validate :promotion_has_enough_rewards
    validate :employee_cannot_redeem_own_promotion
    validate :accounting_fields_are_immutable, on: :update
    validates :points, numericality: { greater_than: 0 }
  end

  begin :callbacks
    after_create :update_user_points
    after_create :update_promotion
    after_create :record_point_movement
  end

  attr_accessor :idempotency_key

  validates :idempotency_key, length: { maximum: 255 }, allow_nil: true

  def self.redeem(user:, employee:, promotion:, invoice_number:, idempotency_key: nil)
    output = new(
      user: user,
      employee: employee,
      promotion: promotion,
      points: promotion.points_required,
      invoice_number: invoice_number
    )
    output.idempotency_key = idempotency_key

    saved = if user
      result = nil
      transaction do
        user.with_lock do
          existing = PointMovement.find_by(user: user, idempotency_key: idempotency_key) if idempotency_key.present?
          if existing
            original = existing.transaction_output
            if original && original.employee_id == employee&.id && original.promotion_id == promotion&.id && original.invoice_number == invoice_number
              result = [original, true, true]
            else
              conflict = original || output
              conflict.errors.add(:base, :idempotency_key_reused)
              result = [conflict, false, false]
            end
          else
            result = [output, promotion.with_lock { output.save }, false]
          end
        end
      end
      result
    else
      [output, output.save, false]
    end
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

  def record_point_movement
    PointMovement.create!(
      user: user,
      transaction_output: self,
      points: -points,
      kind: "redemption",
      idempotency_key: idempotency_key
    )
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

  def accounting_fields_are_immutable
    return unless will_save_change_to_user_id? || will_save_change_to_employee_id? ||
      will_save_change_to_promotion_id? || will_save_change_to_points?

    errors.add(:base, "posted point movements cannot be changed")
  end

end
