# == Schema Information
#
# Table name: notifications
#
#  id           :bigint(8)        not null, primary key
#  message      :string
#  status       :string           default("pending")
#  kind         :string
#  from_user_id :bigint(8)
#  to_user_id   :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Notification < ApplicationRecord

  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_user, :class_name => 'User'

  KIND = [
    "request_employee",
    "invitation_employee",
    "company_approved",
  ].freeze

  STATUS = [
    "pending",
    "approved",
    "disabled",
    "decline"
  ].freeze
end
