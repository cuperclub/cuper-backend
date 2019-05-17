# == Schema Information
#
# Table name: employees
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#  company_id :bigint(8)
#  role       :string
#  feedback   :text
#  status     :string           default("pending")
#

class Employee < ApplicationRecord

  ROLES = [
    "partner",
    "cashier",
  ].freeze

  STATUS = [
    "pending",
    "approved",
    "disabled",
    "deleted"
  ].freeze

  begin :relationships
    belongs_to :user
    belongs_to :company
    has_many :transaction_inputs
    has_many :transaction_outputs
  end

  begin :validations
    validates :user_id, :company_id, :role, presence: true
    validates :role,
              inclusion: { in: ROLES }
    validates :status,
              inclusion: { in: STATUS }
    validate :cant_change_to_pending, on: :update
  end

  private

  def cant_change_to_pending
    if self.status == "pending"
      errors.add(
        :status,
        I18n.t("activerecord.errors.models.employee.cant_change", status: self.status)
      )
    end
  end
end
