require 'rails_helper'

RSpec.describe "CORS", type: :request do
  let(:preflight_headers) do
    {
      "Origin" => "http://localhost:4200",
      "Access-Control-Request-Method" => "GET",
      "Access-Control-Request-Headers" => "access-token,client,uid"
    }
  end

  it "allows the configured local Angular origin without credentialed CORS" do
    options "/api/promotions", headers: preflight_headers

    expect(response).to have_http_status(:ok)
    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:4200")
    expect(response.headers["Access-Control-Allow-Credentials"]).to be_nil
  end

  it "does not grant CORS access to other local origins" do
    options "/api/promotions", headers: preflight_headers.merge("Origin" => "http://localhost:4300")

    expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
  end
end
