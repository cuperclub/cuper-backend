# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  allow_password_change  :boolean          default(FALSE)
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  name                   :string
#  nickname               :string
#  image                  :string
#  email                  :string
#  tokens                 :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  national_id            :string
#  is_admin               :boolean          default(FALSE)
#  active                 :boolean          default(TRUE)
#  points                 :float            default(0.0)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook, :google_oauth2 ]

  include DeviseTokenAuth::Concerns::User

  mount_uploader :image, ApplicationUploader

  scope :by_role, -> (role) {
    includes(:employees).where('employees.role' => role)
  }
  after_create :assign_points

  begin :relationships
    has_many :employees
    has_many :companies, through: :employees
    has_many :transaction_inputs
    has_many :transaction_outputs
    has_one :setting
  end

  begin :validations
    validates :email, presence: true, uniqueness: true
    validates :national_id, uniqueness: true, allow_nil: true
    validates :name, presence: true
  end

  def is_employee
    !!self.employees
  end

  def is_cashier
    !!self.employees.find_by_role("cashier")
  end

  def is_partner
    !!self.employees.find_by_role("partner")
  end

  def my_companies
    self.employees.where(role: "partner")
  end

  def pending_notifications
    Notification.where(to_user_id: self.id, status:"pending").count
  end

  def current_view_company_id
    if self.setting
      self.setting.current_company
    else
      if self.my_companies.count > 0
        self.my_companies.first.company.id
      else
        if self.employees.count > 0 && self.employees.first.status != "pending"
          self.employees.first.company.id
        end
      end
    end
  end

  def expired_plan
    current_plan = PlanCompany.find_by_company_id(self.current_view_company_id)
    if current_plan && current_plan.has_attribute?(:expired)
      day_in_seconds = 86400
      expired_date = current_plan.start_date + (current_plan.plan.days * day_in_seconds)
      is_expired_plan = current_plan.expired
      if expired_date < DateTime.now && !current_plan.expired
        current_plan.expired = true
        current_plan.save
        employee = self.my_employee
        employee.status = "expired"
        employee.save
      end
    end
    is_expired_plan
  end

  def my_employee
    Employee.where(user: self, company_id: self.current_view_company_id).first
  end


  def assign_points
    UtilService.new(self).assign_promo_points
  end
end
