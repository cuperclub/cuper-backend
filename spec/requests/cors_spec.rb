require "rails_helper"

RSpec.describe "CORS", type: :request do
  it "allows the configured local Angular origin" do
    options "/api/transaction_inputs", headers: {
      "Origin" => "http://localhost:4200",
      "Access-Control-Request-Method" => "POST"
    }

    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:4200")
    expect(response.headers["Access-Control-Allow-Methods"]).to include("POST")
  end

  it "does not allow an unconfigured origin" do
    options "/api/transaction_inputs", headers: {
      "Origin" => "https://untrusted.example",
      "Access-Control-Request-Method" => "POST"
    }

    expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
  end
end
