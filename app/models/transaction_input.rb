# == Schema Information
#
# Table name: transaction_inputs
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint(8)
#  employee_id    :bigint(8)
#  points         :bigint(8)
#  invoice_number :string
#

class TransactionInput < ApplicationRecord
  MAX_SAFE_POINT_VALUE = 9_007_199_254_740_991

  begin :relationships
    belongs_to :user
    belongs_to :employee
    has_one :point_movement
  end

  begin :validations
    validate :cannot_assign_yourself
    validate :user_balance_within_safe_integer_range, on: :create
    validate :accounting_fields_are_immutable, on: :update
    validates :points, numericality: { greater_than_or_equal_to: 0 }
    validates :idempotency_key, length: { maximum: 255 }, allow_nil: true
  end

  begin :callbacks
    after_create :update_user_points
    after_create :record_point_movement
  end

  attr_accessor :idempotency_key

  def self.accrue(user:, employee:, points:, invoice_number:, idempotency_key: nil)
    input = new(user: user, employee: employee, points: points, invoice_number: invoice_number)
    input.idempotency_key = idempotency_key
    saved = if user
      result = nil
      transaction do
        user.with_lock do
          existing = PointMovement.find_by(user: user, idempotency_key: idempotency_key) if idempotency_key.present?
          if existing
            original = existing.transaction_input
            if original && original.employee_id == employee&.id && original.points == points && original.invoice_number == invoice_number
              result = [original, true, true]
            else
              conflict = original || input
              conflict.errors.add(:base, :idempotency_key_reused)
              result = [conflict, false, false]
            end
          else
            result = [input, input.save, false]
          end
        end
      end
      result
    else
      [input, input.save, false]
    end
  end

  def update_user_points
    user.update!(points: (user.points || 0) + points)
  end

  def record_point_movement
    PointMovement.create!(
      user: user,
      transaction_input: self,
      points: points,
      kind: "accrual",
      idempotency_key: idempotency_key
    )
  end

  def cannot_assign_yourself
    if employee && (user == employee.user)
      errors.add(
        :user,
        I18n.t("activerecord.errors.models.transaction_input.user")
      )
    end
  end

  def user_balance_within_safe_integer_range
    return unless user && points

    balance = (user.points || 0) + points
    return if balance.between?(-MAX_SAFE_POINT_VALUE, MAX_SAFE_POINT_VALUE)

    errors.add(:points, "would exceed the exact balance range")
  end

  def accounting_fields_are_immutable
    return unless will_save_change_to_user_id? || will_save_change_to_employee_id? || will_save_change_to_points?

    errors.add(:base, "posted point movements cannot be changed")
  end

end
