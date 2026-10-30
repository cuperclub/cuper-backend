require 'rails_helper'

RSpec.describe Api::Partner::EmployeesController, type: :controller do
  it "scopes status changes to the partner company and ignores role changes" do
    partner = create(:employee, role: "partner", status: "approved")
    cashier = create(:employee,
      user: create(:user, email: "managed-cashier@example.com", national_id: "managed-cashier"),
      company: partner.company,
      role: "cashier",
      status: "pending")
    other_company_employee = create(:employee,
      user: create(:user, email: "other-cashier@example.com", national_id: "other-cashier"),
      company: create(:company, ruc: "other-company-ruc"),
      role: "cashier",
      status: "pending")
    request.headers.merge!(partner.user.create_new_auth_token)

    put :update_state, params: {
      id: cashier.id,
      employee: { status: "approved", role: "partner" }
    }, format: :json

    expect(response).to have_http_status(:accepted)
    expect(cashier.reload.status).to eq("approved")
    expect(cashier.role).to eq("cashier")

    put :update_state, params: {
      id: other_company_employee.id,
      employee: { status: "approved" }
    }, format: :json

    expect(response).to have_http_status(:not_found)
    expect(other_company_employee.reload.status).to eq("pending")
  end

  it "does not allow a pending partner to manage company employees" do
    partner = create(:employee, role: "partner", status: "pending")
    request.headers.merge!(partner.user.create_new_auth_token)

    get :index, format: :json

    expect(response).to have_http_status(:not_found)
  end
end
