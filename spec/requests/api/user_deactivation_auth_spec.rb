require 'rails_helper'

RSpec.describe "Authentication after user deactivation", type: :request do
  it "revokes existing tokens when a user is deactivated" do
    user = create(:user)
    auth_headers = user.create_new_auth_token
    user.update!(active: false)

    expect(user.reload.tokens).to be_empty

    get "/api/promotions", headers: auth_headers

    expect(response).to have_http_status(:unauthorized)

    user.update!(active: true)
    get "/api/promotions", headers: auth_headers

    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects existing tokens for legacy deactivated users" do
    user = create(:user)
    auth_headers = user.create_new_auth_token
    user.update_column(:active, false)

    get "/api/promotions", headers: auth_headers

    expect(response).to have_http_status(:unauthorized)
  end

  it "does not issue tokens to a deactivated user" do
    plan = create(:plan)
    AppSetting.create!(plan_selected_id: plan.id, points_by_register: 0, main_employee_id: 1)
    user = create(:user, active: false)

    post "/auth/sign_in",
      params: { email: user.email, password: "123123123" },
      as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
