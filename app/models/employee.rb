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
    "deleted",
    "declined"
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

  after_update :send_status_notification_email
  after_create :send_register_notification_email

  def employeer_company
    if self.role == "cashier"
      self.company
    end
  end

  def my_company
    if self.role == "partner"
      self.company
    end
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

  def send_status_notification_email
    if self.role == 'partner'
      status = I18n.t("models.employee.status.#{self.status}")
      CompanyMailer.notify_company_status_updated(self.user, self.company, status, self.feedback).deliver_now
    end
  end

  def send_register_notification_email
    if self.role == 'partner'
      CompanyMailer.notify_company_registered(self.user, self.company, 'cuperclubec@gmail.com').deliver_now
    end
  end
end
