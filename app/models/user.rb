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
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  mount_uploader :image, ApplicationUploader

  scope :by_role, -> (role) {
    includes(:employee).where('employees.role' => role)
  }

  begin :relationships
    has_one :employee
    has_one :company, through: :employee
    has_many :transaction_inputs
    has_many :transaction_outputs
  end

  begin :validations
    validates :email, presence: true, uniqueness: true
    validates :national_id, uniqueness: true, allow_nil: true
    validates :name, presence: true
  end

  def is_employee
    !!employee
  end

  def is_cashier
    !!(employee and employee.role == 'cashier')
  end

  def is_partner
    !!(employee and employee.role == 'partner')
  end

  def is_client
    !employee
  end

end
