require 'rails_helper'

RSpec.describe Api::Admin::UsersController, type: :controller do

  describe "GET #index" do
    let(:admin) { create :user, :admin }
    let(:user) { create :user }

    it "returns http success for admins" do
      request.headers.merge!(admin.create_new_auth_token)
      get :index, :format => :json
      expect(response).to have_http_status(:success)
    end

    it "returns http unauthorized with non logged in users" do
      get :index, :format => :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns http unauthorized with logged in user but not admin" do
      login_as user
      get :index, :format => :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT #toggle_status" do
    let(:admin) { create :user, :admin }
    let(:user) { create :user }

    it "rejects non-admins without changing the user" do
      login_as user

      put :toggle_status, params: { id: admin.id }, format: :json

      expect(response).to have_http_status(:unauthorized)
      expect(admin.reload.active).to be true
    end
  end

  describe "PUT #update_password" do
    it "sends a reset instruction instead of setting or emailing a password" do
      admin = create(:user, :admin)
      user = create(:user, email: "reset@example.com", national_id: "reset-1")
      encrypted_password = user.encrypted_password
      login_as admin

      put :update_password, params: { id: user.id, password: "plaintext-secret" }, format: :json

      expect(response).to have_http_status(:ok)
      expect(user.reload.encrypted_password).to eq(encrypted_password)
      expect(user.reset_password_token).to be_present
      expect(ActionMailer::Base.deliveries.last.body.encoded).not_to include("plaintext-secret")
    end
  end
end
