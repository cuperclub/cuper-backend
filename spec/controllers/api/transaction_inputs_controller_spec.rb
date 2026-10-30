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
    end

    it "accepts numeric strings from form-encoded clients" do
      request.headers.merge!(employee.user.create_new_auth_token)

      post :create, params: { transaction_input: { user_id: user.id, points: "10" } }, format: :json

      expect(response).to have_http_status(:created)
      expect(user.reload.points).to eq(10)
    end

    it "rejects missing or malformed point amounts without changing the balance" do
      request.headers.merge!(employee.user.create_new_auth_token)
      [nil, "not-a-number", "Infinity"].each do |points|
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
