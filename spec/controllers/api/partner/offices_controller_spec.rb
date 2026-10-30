require 'rails_helper'

RSpec.describe Api::Partner::OfficesController, type: :controller do
  describe "PUT #toggle_status" do
    let(:office) { create(:office) }

    it "allows an approved partner to toggle their own office" do
      employee = create(:employee, company: office.company, role: "partner", status: "approved")
      request.headers.merge!(employee.user.create_new_auth_token)

      put :toggle_status, params: { id: office.id }, format: :json

      expect(response).to have_http_status(:success)
    end

    it "rejects a user without a partner membership" do
      request.headers.merge!(create(:user).create_new_auth_token)

      put :toggle_status, params: { id: office.id }, format: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  it "creates an office in the partner's company, ignoring a submitted company id" do
    employee = create(:employee, role: "partner", status: "approved")
    other_company = create(:company, ruc: "987654321")
    request.headers.merge!(employee.user.create_new_auth_token)

    post :create, params: { office: { name: "Partner office", address: "Main St", company_id: other_company.id } }, format: :json

    expect(response).to have_http_status(:created)
    expect(employee.company.offices.find_by!(name: "Partner office").company_id).to eq(employee.company_id)
    expect(other_company.offices.where(name: "Partner office")).to be_empty
  end

  it "does not expose partner offices to a cashier membership" do
    employee = create(:employee, role: "cashier", status: "approved")
    request.headers.merge!(employee.user.create_new_auth_token)

    get :index, format: :json

    expect(response).to have_http_status(:not_found)
  end
end
