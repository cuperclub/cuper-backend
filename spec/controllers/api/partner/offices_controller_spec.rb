require 'rails_helper'

RSpec.describe Api::Partner::OfficesController, type: :controller do

  describe "PUT #toggle_status" do
    let(:office) { create :office }
    let(:employee) { create :employee, company: office.company }
    let(:user) { create :user }

    it "returns http success" do
      login_as employee.user
      put :toggle_status, params: { id: office.id }, :format => :json
      expect(response).to have_http_status(:success)
    end

    it "returns http unauthorized when the user is not partner" do
      login_as user
      put :toggle_status, params: { id: office.id }, :format => :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

end
