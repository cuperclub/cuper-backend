require 'rails_helper'

RSpec.describe Api::TransactionInputsController, type: :controller do
  describe "POST #create" do
    let(:user) { create :user }
    let(:employee) { create :employee, role: "cashier", status: "approved" }
    render_views

    it "returns http unprocessable_entity if the user with national_id X is not found" do
      request.headers.merge!(employee.user.create_new_auth_token)
      post :create, params: {transaction_input: {national_id: "x", points: 10, invoice_number: "123123123"}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns http created when a user receives a transaction input" do
      request.headers.merge!(employee.user.create_new_auth_token)
      post :create, params: {transaction_input: {user_id: user.id, points: 10, invoice_number: "123123123"}} , :format => :json
      expect(response).to have_http_status(:created)
      expect(user.reload.points).to eq(10)
      expect(PointMovement.last.attributes.slice("user_id", "points", "kind")).to eq(
        "user_id" => user.id,
        "points" => 10,
        "kind" => "accrual"
      )
    end

    it "replays an accrual idempotently without repeating its notification" do
      request.headers.merge!(employee.user.create_new_auth_token)
      request.headers["Idempotency-Key"] = "input-retry-1"
      attributes = { user_id: user.id, points: 10, invoice_number: "invoice-1" }

      post :create, params: { transaction_input: attributes }, format: :json
      expect(response).to have_http_status(:created)
      post :create, params: { transaction_input: attributes }, format: :json

      expect(response).to have_http_status(:created)
      expect(TransactionInput.where(user: user).count).to eq(1)
      expect(PointMovement.where(user: user).count).to eq(1)
      expect(user.reload.points).to eq(10)
      expect(Notification.where(to_user_id: user.id, kind: "assign_points").count).to eq(1)
    end

    it "returns conflict when an idempotency key is reused for a different accrual" do
      request.headers.merge!(employee.user.create_new_auth_token)
      request.headers["Idempotency-Key"] = "input-retry-2"

      post :create, params: { transaction_input: { user_id: user.id, points: 10 } }, format: :json
      post :create, params: { transaction_input: { user_id: user.id, points: 11 } }, format: :json

      expect(response).to have_http_status(:conflict)
      expect(TransactionInput.where(user: user).count).to eq(1)
      expect(user.reload.points).to eq(10)
    end

    it "accepts numeric strings from form-encoded clients" do
      request.headers.merge!(employee.user.create_new_auth_token)

      post :create, params: { transaction_input: { user_id: user.id, points: "10" } }, format: :json

      expect(response).to have_http_status(:created)
      expect(user.reload.points).to eq(10)
    end

    it "stores integer points using exact decimal accrual math" do
      employee.company.category.update_column(:points_per_dollar, 4)
      request.headers.merge!(employee.user.create_new_auth_token)

      post :create, params: { transaction_input: { user_id: user.id, points: "1.25" } }, format: :json

      expect(response).to have_http_status(:created)
      expect(TransactionInput.last.points % 1).to eq(0)
      expect(user.reload.points % 1).to eq(0)
      expect(user.points).to eq(5)
    end

    it "rounds fractional accruals to the nearest whole point" do
      employee.company.category.update_column(:points_per_dollar, 1)
      request.headers.merge!(employee.user.create_new_auth_token)

      post :create, params: { transaction_input: { user_id: user.id, points: "0.5" } }, format: :json

      expect(response).to have_http_status(:created)
      expect(TransactionInput.last.points).to eq(1)
      expect(user.reload.points).to eq(1)
    end

    it "records an accrual that rounds to zero points" do
      employee.company.category.update_column(:points_per_dollar, 1)
      request.headers.merge!(employee.user.create_new_auth_token)

      post :create, params: { transaction_input: { user_id: user.id, points: "0.25" } }, format: :json

      expect(response).to have_http_status(:created)
      expect(TransactionInput.last.points).to eq(0)
      expect(user.reload.points).to eq(0)
    end

    it "rejects accruals that would exceed the exact integer balance range" do
      user.update_column(:points, TransactionInput::MAX_SAFE_POINT_VALUE)
      request.headers.merge!(employee.user.create_new_auth_token)

      post :create, params: { transaction_input: { user_id: user.id, points: "1" } }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.points).to eq(TransactionInput::MAX_SAFE_POINT_VALUE)
      expect(TransactionInput.where(user: user)).to be_empty
    end

    it "rejects missing or malformed point amounts without changing the balance" do
      request.headers.merge!(employee.user.create_new_auth_token)
      [nil, "not-a-number", "Infinity", "0"].each do |points|
        attributes = { user_id: user.id }
        attributes[:points] = points unless points.nil?

        post :create, params: { transaction_input: attributes }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      expect(user.reload.points).to eq(0)
      expect(TransactionInput.where(user: user)).to be_empty
    end

    it "rejects overflow and a missing legacy category multiplier" do
      request.headers.merge!(employee.user.create_new_auth_token)
      employee.company.category.update_column(:points_per_dollar, 2)

      post :create, params: { transaction_input: { user_id: user.id, points: "1e308" } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)

      employee.company.category.update_column(:points_per_dollar, nil)
      post :create, params: { transaction_input: { user_id: user.id, points: 1 } }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.points).to eq(0)
      expect(TransactionInput.where(user: user)).to be_empty
    end

    it "accrues points to a legacy user with a null balance" do
      customer = create(:user, email: "null-balance@example.com", national_id: "null-balance", points: nil)
      request.headers.merge!(employee.user.create_new_auth_token)

      post :create, params: { transaction_input: { user_id: customer.id, points: 3 } }, format: :json

      expect(response).to have_http_status(:created)
      expect(customer.reload.points).to eq(3)
    end

    it "returns http unprocessable_entity if the employee assigns points to himself" do
      request.headers.merge!(employee.user.create_new_auth_token)
      post :create, params: {transaction_input: {national_id: employee.user.national_id, points: 10, invoice_number: "123123123"}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
