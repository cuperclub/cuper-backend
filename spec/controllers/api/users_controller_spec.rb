require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe "GET #search" do
    render_views

    it "keeps accent-insensitive matching, excludes the current user, and limits results to ten" do
      current_user = create(:user, name: "José Current", email: "current@example.com", national_id: "current")
      matches = 12.times.map do |index|
        create(:user,
               name: "José Client #{index}",
               email: "client#{index}@example.com",
               national_id: "client-#{index}")
      end
      allow(controller).to receive(:authenticate_user!)
      allow(controller).to receive(:current_user).and_return(current_user)

      get :search, params: { query: "jose" }, format: :json

      expect(response).to have_http_status(:ok)
      result_ids = JSON.parse(response.body).map { |user| user["national_id"] }
      expect(result_ids.length).to eq(10)
      expect(result_ids).not_to include(current_user.national_id)
      expect(result_ids).to all(be_in(matches.map(&:national_id)))
    end
  end

  describe "PUT #current_view" do
    it "rejects a company without an approved membership" do
      user = create(:user)
      company = create(:company)
      allow(controller).to receive(:authenticate_user!)
      allow(controller).to receive(:current_user).and_return(user)

      put :current_view, params: { company_id: company.id }, format: :json

      expect(response).to have_http_status(:forbidden)
      expect(user.reload.setting).to be_nil
    end

    it "stores a company with an approved membership" do
      employee = create(:employee, status: "approved")
      allow(controller).to receive(:authenticate_user!)
      allow(controller).to receive(:current_user).and_return(employee.user)

      put :current_view, params: { company_id: employee.company_id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(employee.user.reload.setting.current_company).to eq(employee.company_id)
    end
  end
end
