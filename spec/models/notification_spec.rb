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

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it "rejects a duplicate pending employee request from the same sender" do
    sender = create(:employee, role: "partner")
    recipient = create(:user)
    attributes = {
      from_user: sender.user,
      from_employee: sender,
      to_user: recipient,
      kind: "request_employee",
      status: "pending"
    }
    create(:notification, **attributes)

    duplicate = build(:notification, **attributes)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:to_user]).to be_present
  end

  describe "#send_pusher_notification!" do
    let(:notification) do
      create(
        :notification,
        from_user: create(:user, email: "pusher-sender@example.test", national_id: "pusher-sender"),
        to_user: create(:user, email: "pusher-recipient@example.test", national_id: "pusher-recipient"),
        message: "sensitive notification content"
      )
    end

    it "logs delivery without including notification content" do
      allow(Pusher).to receive(:trigger)
      expect(Rails.logger).to receive(:info).with("Pusher notification delivered (notification_id=#{notification.id})")

      notification.send_pusher_notification!
    end

    it "logs only the exception class when delivery fails" do
      allow(Pusher).to receive(:trigger).and_raise(StandardError, "sensitive provider response")
      expect(Rails.logger).to receive(:error).with("Pusher notification failed (notification_id=#{notification.id}, error=StandardError)")

      notification.send_pusher_notification!
    end
  end
end
