require 'rails_helper'

RSpec.describe Api::TransactionInputsController, type: :controller do
  describe "POST #create" do
    let(:user) { create :user }
    let(:employee) { create :employee }
    render_views

    it "returns http unprocessable_entity if the user with national_id X not found" do
      login_as employee.user
      post :create, params: {transaction_input: {national_id: "x", points: 10, invoice_number: "123123123"}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns http created if the user created succesfuly a transaction input" do
      login_as employee.user
      post :create, params: {transaction_input: {national_id: user.national_id, points: 10, invoice_number: "123123123"}} , :format => :json
      expect(response).to have_http_status(:created)
    end

    it "returns http unprocessable_entity if the user is assigning himself" do
      login_as employee.user
      post :create, params: {transaction_input: {national_id: employee.user.national_id, points: 10, invoice_number: "123123123"}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
