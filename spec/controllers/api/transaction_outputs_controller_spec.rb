require 'rails_helper'

RSpec.describe Api::TransactionOutputsController, type: :controller do
  describe "POST #create" do
    let(:user) { create :user, points: 10 }
    let(:promotion) { create :promotion, total_rewards: 10 }
    let(:employee) { create :employee, company: promotion.office.company }

    render_views

    skip "returns http unprocessable_entity if the user with national_id X not found" do
      login_as employee.user
      post :create, params: {transaction_output: {national_id: "x", points: 10, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    skip "returns http created if the user created succesfuly a transaction output" do
      login_as employee.user
      post :create, params: {transaction_output: {national_id: user.national_id, points: 10, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      print response.body
      expect(response).to have_http_status(:created)
    end

    skip "returns http unprocessable_entity if the user is assigning himself" do
      login_as employee.user
      post :create, params: {transaction_output: {national_id: employee.user.national_id, points: 10, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    skip "returns http unprocessable_entity if the user don't have enough points" do
      login_as employee.user
      post :create, params: {transaction_output: {national_id: employee.user.national_id, points: 1000, invoice_number: "123123123", promotion_id: promotion.id}} , :format => :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end
end
