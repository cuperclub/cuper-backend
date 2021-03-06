# == Schema Information
#
# Table name: notifications
#
#  id               :bigint(8)        not null, primary key
#  message          :string
#  status           :string           default("pending")
#  kind             :string
#  from_employee_id :bigint(8)
#  from_user_id     :bigint(8)
#  to_user_id       :bigint(8)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Notification < ApplicationRecord

  belongs_to :from_user, :class_name => 'User'
  belongs_to :from_employee, :class_name => 'Employee', required: false
  belongs_to :to_user, :class_name => 'User'
  after_create :notify_user!

  begin :validations
    validates_uniqueness_of :to_user, scope: [:from_user, :from_employee],
                            if: -> {kind == 'request_employee' && status == 'pending'},
                            message: I18n.t("activerecord.errors.models.notification.twice_request_employee")
  end

  KIND = [
    "request_employee",
    "answer_request_employee",
    "invitation_employee",
    "company_status",
    "inital_points",
    "assign_points",
    "assign_promotion"
  ].freeze

  STATUS = [
    "pending",
    "approved",
    "disabled",
    "decline",
    "read"
  ].freeze

  def notify_user!
    unless Rails.env.test?
      if Rails.env.production?
        # delay.send_pusher_notification!
      else
        send_pusher_notification!
      end
    end
  end

  def send_pusher_notification!
    notification_data = self
    user_channel_general = "usernotifications.#{self.to_user_id}"
    begin
      Pusher.trigger(user_channel_general, 'new-notification', notification_data)
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    else
      puts "PUSHER: Message sent successfully!"
      puts "PUSHER: #{notification_data}"
    end
  end
end
