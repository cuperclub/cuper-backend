require 'rails_helper'

RSpec.describe "API session middleware", type: :request do
  it "completes an unauthenticated request through Rails cookie-session middleware" do
    get "/api/promotions", headers: { "ACCEPT" => "application/json" }

    expect(response).to have_http_status(:unauthorized)
    expect(response.media_type).to eq("application/json")
  end
end
