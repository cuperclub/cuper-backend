require 'rails_helper'

RSpec.describe Api::TransactionOutputsController, type: :controller do
  describe "POST #create" do
    let(:user) { create :user, points: 10 }
    let(:promotion) { create :promotion, total_rewards: 10, points_required: 5 }
    let(:employee) { create :employee, company: promotion.office.company, role: "cashier", status: "approved" }

    render_views

    it "returns http unprocessable_entity if the user with national_id X is not found" do
      request.headers.merge!(employee.user.create_new_auth_token)
      post :create, params: {transaction_output: {national_id: "x", points: 10, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns http created when a user redeems a promotion" do
      request.headers.merge!(employee.user.create_new_auth_token)
      post :create, params: {transaction_output: {national_id: user.national_id, points: 10, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      expect(response).to have_http_status(:created)
      expect(user.reload.points).to eq(5)
    end

    it "returns http unprocessable_entity if the employee redeems their own promotion" do
      request.headers.merge!(employee.user.create_new_auth_token)
      post :create, params: {transaction_output: {national_id: employee.user.national_id, points: 10, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns http unprocessable_entity if the user does not have enough points" do
      poor_user = create(:user, email: "poor@example.com", national_id: "poor-1", points: 4)
      request.headers.merge!(employee.user.create_new_auth_token)
      post :create, params: {transaction_output: {user_id: poor_user.id, points: 1, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end
end
