require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe "PUT #current_view" do
    it "rejects a company without an approved membership" do
      user = create(:user)
      company = create(:company)
      login_as user

      put :current_view, params: { company_id: company.id }, format: :json

      expect(response).to have_http_status(:forbidden)
      expect(user.reload.setting).to be_nil
    end

    it "stores a company with an approved membership" do
      employee = create(:employee, status: "approved")
      login_as employee.user

      put :current_view, params: { company_id: employee.company_id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(employee.user.reload.setting.current_company).to eq(employee.company_id)
    end
  end
end
