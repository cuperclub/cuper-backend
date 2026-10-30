require 'rails_helper'

RSpec.describe Api::Partner::CompaniesController, type: :controller do
  let(:user) { create(:user, email: "company-applicant@example.com", national_id: "company-applicant") }
  let(:category) { create(:category) }

  before do
    request.headers.merge!(user.create_new_auth_token)
  end

  it "creates the company, partner membership, plan and current view together" do
    plan = create(:plan)

    expect do
      post :create, params: {
        ruc: "company-applicant-ruc",
        business_name: "Applicant Company",
        legal_representative: "Applicant",
        category_id: category.id,
        plan_id: plan.id
      }, format: :json
    end.to change(Company, :count).by(1)
      .and change(Employee, :count).by(1)
      .and change(PlanCompany, :count).by(1)
      .and change(Setting, :count).by(1)

    company = Company.find_by!(ruc: "company-applicant-ruc")
    expect(company.employees.find_by!(user: user).role).to eq("partner")
    expect(user.reload.setting.current_company).to eq(company.id)
    expect(response).to have_http_status(:created)
  end

  it "rolls back the application if the selected plan is invalid" do
    expect do
      post :create, params: {
        ruc: "invalid-plan-ruc",
        business_name: "Applicant Company",
        legal_representative: "Applicant",
        category_id: category.id,
        plan_id: -1
      }, format: :json
    end.not_to change(Company, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(Employee.where(user: user)).to be_empty
    expect(user.reload.setting).to be_nil
  end

  it "rejects an employee invitation when the user already has a company membership" do
    company = create(:company)
    create(:employee, user: user, company: company, role: "partner", status: "approved")
    existing_employee = create(:employee,
      user: create(:user, email: "existing-member@example.com", national_id: "existing-member"),
      company: company,
      role: "cashier",
      status: "disabled")

    post :request_employee, params: { user_id: existing_employee.user_id }, format: :json

    expect(response).to have_http_status(:conflict)
    expect(Notification.where(kind: "request_employee", to_user_id: existing_employee.user_id)).to be_empty
  end
end
