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

  before_save :revoke_tokens_when_deactivated

  def is_employee
    employees.exists?(status: "approved")
  end

  def active_for_authentication?
    super && active?
  end

  def valid_token?(token, client = "default")
    active? && super
  end

  def is_cashier
    employees.exists?(role: "cashier", status: "approved")
  end

  def is_partner
    employees.exists?(role: "partner", status: "approved")
  end

  def my_companies
    self.employees.where(role: "partner")
  end

  def pending_notifications
    Notification.where(to_user_id: self.id, status:"pending").count
  end

  def current_view_company_id
    approved_employees = employees.where(status: "approved")
    approved_employees.find_by(company_id: setting&.current_company)&.company_id ||
      approved_employees.find_by(role: "partner")&.company_id ||
      approved_employees.first&.company_id
  end

  def my_employee
    employees.find_by(company_id: current_view_company_id, role: "partner", status: "approved")
  end


  def assign_points
    UtilService.new(self).assign_promo_points
  end

  private

  def revoke_tokens_when_deactivated
    self.tokens = {} if will_save_change_to_active? && !active?
  end
end
