require 'rails_helper'

RSpec.describe "Sensitive parameter logging filters", type: :request do
  it "filters credentials and personal identifiers from logged parameters" do
    filtered = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters).filter(
      email: "customer@example.test",
      national_id: "test-national-id",
      password_confirmation: "test-password",
      access_token: "test-access-token",
      name: "Visible Name"
    )

    expect(filtered).to eq(
      email: "[FILTERED]",
      national_id: "[FILTERED]",
      password_confirmation: "[FILTERED]",
      access_token: "[FILTERED]",
      name: "Visible Name"
    )
  end
end
