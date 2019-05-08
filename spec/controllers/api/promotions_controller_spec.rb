require 'rails_helper'

RSpec.describe Api::PromotionsController, type: :controller do

  describe "GET #index" do
    let(:user) { create :user }

    it "returns http unauthorized with non logged in users" do
      get :index, :format => :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns http success with logged in user" do
      login_as user
      get :index, :format => :json
      expect(response).to have_http_status(:success)
    end

  end

  describe "GET #show" do
    let(:user) { create :user }
    let(:promotion) { create :promotion }

    it "returns http unauthorized with non logged in users" do
      get :show, params: { id: promotion.id }, :format => :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns http success with logged in users" do
      login_as user
      get :show, params: { id: promotion.id }, :format => :json
      expect(response).to have_http_status(:success)
    end
  end

end
