require 'rails_helper'

RSpec.describe Api::Cashier::ProfilesController, type: :controller do
  it "does not create duplicate applications for the same company" do
    user = create(:user, email: "cashier-applicant@example.com", national_id: "cashier-applicant")
    company = create(:company)
    request.headers.merge!(user.create_new_auth_token)

    post :create, params: { company_id: company.id }, format: :json

    expect(response).to have_http_status(:accepted)
    expect do
      post :create, params: { company_id: company.id }, format: :json
    end.not_to change(Employee, :count)

    expect(response).to have_http_status(:conflict)
    expect(Employee.where(user: user, company: company).count).to eq(1)
  end
end
