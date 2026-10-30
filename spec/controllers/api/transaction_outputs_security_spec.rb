require 'rails_helper'

RSpec.describe Api::TransactionOutputsController, type: :controller do
  it "uses the company's promotion and its configured price, not client-supplied values" do
    employee = create(:employee, role: "cashier", status: "approved")
    customer = create(:user, email: "redeem@example.com", national_id: "redeem-1", points: 10)
    promotion = create(:promotion, office: create(:office, company: employee.company), total_rewards: 1, points_required: 5)
    request.headers.merge!(employee.user.create_new_auth_token)

    post :create, params: {
      transaction_output: {
        user_id: customer.id,
        promotion_id: promotion.id,
        points: 1,
        invoice_number: "invoice-1"
      }
    }, format: :json

    expect(response).to have_http_status(:created)
    expect(TransactionOutput.last.points).to eq(5)
    expect(customer.reload.points).to eq(5)
  end

  it "rejects redemption of a promotion belonging to another company" do
    employee = create(:employee, role: "cashier", status: "approved")
    customer = create(:user, email: "other-redeem@example.com", national_id: "other-redeem-1", points: 10)
    other_company = create(:company, ruc: "987654321")
    promotion = create(:promotion, office: create(:office, company: other_company), total_rewards: 1, points_required: 5)
    request.headers.merge!(employee.user.create_new_auth_token)

    expect do
      post :create, params: {
        transaction_output: {
          user_id: customer.id,
          promotion_id: promotion.id,
          points: 1
        }
      }, format: :json
    end.not_to change(TransactionOutput, :count)

    expect(response).to have_http_status(:not_found)
    expect(customer.reload.points).to eq(10)
  end
end
