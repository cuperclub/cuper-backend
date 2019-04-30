require 'rails_helper'

RSpec.describe Api::Admin::UsersController, type: :controller do

  describe "GET #index" do
    let(:admin) { create :user, :admin }
    let(:user) { create :user }

    it "returns http success" do
      login_as admin
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

end
