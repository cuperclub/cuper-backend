require 'rails_helper'

RSpec.describe Api::Partner::OfficePolicy do
  it "allows an approved partner only for their own company's office" do
    company = create(:company)
    office = create(:office, company: company)
    employee = create(:employee, company: company, role: "partner", status: "approved")

    expect(described_class.new(employee.user, office).toggle_status?).to be true
    expect(described_class.new(create(:user), office).toggle_status?).to be false
  end

  it "does not allow a partner from another company" do
    office = create(:office)
    other_company = create(:company, ruc: "987654321")
    employee = create(:employee, company: other_company, role: "partner", status: "approved")

    expect(described_class.new(employee.user, office).toggle_status?).to be false
  end
end
