require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do

  describe "GET #index" do
    let(:admin) { create :user, :admin }

    it "returns http success" do
      login_as admin
      get :index, :format => :json
      expect(response).to have_http_status(:success)
    end

    it "returns http unauthorized with non logged in users" do
      get :index, :format => :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

end
