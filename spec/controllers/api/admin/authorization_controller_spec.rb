require 'rails_helper'

RSpec.describe Api::Admin::CategoriesController, type: :controller do
  it "rejects category creation by non-admin users" do
    request.headers.merge!(create(:user).create_new_auth_token)

    expect do
      post :create, params: { category: { name: "Restricted", points_per_dollar: 2 } }, format: :json
    end.not_to change(Category, :count)

    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.describe Api::Admin::CompaniesController, type: :controller do
  it "rejects company listing for non-admin users" do
    request.headers.merge!(create(:user).create_new_auth_token)

    get :index, format: :json

    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.describe Api::Admin::AppSettingsController, type: :controller do
  it "rejects settings reads for non-admin users" do
    request.headers.merge!(create(:user).create_new_auth_token)

    get :settings, format: :json

    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.describe Api::Admin::PlansController, type: :controller do
  it "requires authentication to list plans" do
    get :index, format: :json

    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects plan creation for non-admin users" do
    request.headers.merge!(create(:user).create_new_auth_token)

    expect do
      post :create, params: { plan: { name: "Restricted", price: 10, days: 30 } }, format: :json
    end.not_to change(Plan, :count)

    expect(response).to have_http_status(:unauthorized)
  end

  it "requires authentication to create a plan" do
    expect do
      post :create, params: { plan: { name: "Restricted", price: 10, days: 30 } }, format: :json
    end.not_to change(Plan, :count)

    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects plan updates for non-admin users" do
    plan = create(:plan, name: "Original")
    request.headers.merge!(create(:user).create_new_auth_token)

    put :update, params: { id: plan.id, plan: { name: "Changed" } }, format: :json

    expect(response).to have_http_status(:unauthorized)
    expect(plan.reload.name).to eq("Original")
  end
end
