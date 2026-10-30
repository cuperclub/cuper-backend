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
      expect(PointMovement.last.attributes.slice("user_id", "points", "kind")).to eq(
        "user_id" => user.id,
        "points" => -5,
        "kind" => "redemption"
      )
    end

    it "replays a redemption idempotently without spending points or stock twice" do
      request.headers.merge!(employee.user.create_new_auth_token)
      request.headers["Idempotency-Key"] = "output-retry-1"
      attributes = { user_id: user.id, promotion_id: promotion.id, invoice_number: "invoice-1" }

      post :create, params: { transaction_output: attributes }, format: :json
      expect(response).to have_http_status(:created)
      post :create, params: { transaction_output: attributes }, format: :json

      expect(response).to have_http_status(:created)
      expect(TransactionOutput.where(user: user).count).to eq(1)
      expect(PointMovement.where(user: user).count).to eq(1)
      expect(user.reload.points).to eq(5)
      expect(promotion.reload.total_rewards).to eq(9)
    end

    it "returns conflict when an idempotency key is reused for a different redemption" do
      other_promotion = create(:promotion,
        office: promotion.office,
        total_rewards: 10,
        points_required: 4)
      request.headers.merge!(employee.user.create_new_auth_token)
      request.headers["Idempotency-Key"] = "output-retry-2"

      post :create, params: { transaction_output: { user_id: user.id, promotion_id: promotion.id } }, format: :json
      post :create, params: { transaction_output: { user_id: user.id, promotion_id: other_promotion.id } }, format: :json

      expect(response).to have_http_status(:conflict)
      expect(TransactionOutput.where(user: user).count).to eq(1)
      expect(user.reload.points).to eq(5)
      expect(promotion.reload.total_rewards).to eq(9)
      expect(other_promotion.reload.total_rewards).to eq(10)
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
