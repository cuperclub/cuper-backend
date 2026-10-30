require 'rails_helper'

RSpec.describe UtilService do
  it "creates only one pending employee request for concurrent attempts" do
    partner = create(:user, email: "request-partner@example.com", national_id: "request-partner")
    recipient = create(:user, email: "request-recipient@example.com", national_id: "request-recipient")
    company = create(:company)
    create(:employee, user: partner, company: company, role: "partner", status: "approved", skip_notification_email: true)
    ready = Queue.new
    start = Queue.new

    attempts = 2.times.map do
      Thread.new do
        ready << true
        start.pop
        request = described_class.new(User.find(recipient.id), User.find(partner.id)).notify_employee_request
        request.persisted?
      end
    end

    2.times { ready.pop }
    2.times { start << true }
    results = attempts.map(&:value)

    expect(results.count(true)).to eq(1)
    expect(results.count(false)).to eq(1)
    expect(Notification.where(kind: "request_employee", from_user: partner, to_user: recipient, status: "pending").count).to eq(1)
  end
end
