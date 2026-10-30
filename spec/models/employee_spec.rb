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

require 'rails_helper'

RSpec.describe Employee, type: :model do
  it "rejects roles and statuses outside the supported sets" do
    employee = build(:employee, role: "manager", status: "active")

    expect(employee).not_to be_valid
    expect(employee.errors.attribute_names).to include(:role, :status)
  end

  it "does not allow an existing membership to return to pending" do
    employee = create(:employee, status: "approved", skip_notification_email: true)

    expect(employee.update(status: "pending")).to be(false)
    expect(employee.reload.status).to eq("approved")
  end
end
