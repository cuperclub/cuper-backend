require 'rails_helper'

RSpec.describe Employee, type: :model do
  it "does not send a status email when the update transaction rolls back" do
    employee = create(:employee, role: "partner", status: "approved", skip_notification_email: true)
    employee.skip_notification_email = false
    ActionMailer::Base.deliveries.clear

    Employee.transaction(requires_new: true) do
      employee.update!(status: "disabled")
      raise ActiveRecord::Rollback
    end

    expect(employee.reload.status).to eq("approved")
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
