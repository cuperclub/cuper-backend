require 'rails_helper'

RSpec.describe Api::NotificationsController, type: :controller do
  it "does not allow a user to answer another user's notification" do
    recipient = create(:user, email: "recipient@example.com", national_id: "recipient-1")
    other_user = create(:user, email: "other@example.com", national_id: "other-1")
    employee = create(:employee, role: "partner", status: "approved")
    notification = create(:notification,
      from_user: employee.user,
      from_employee: employee,
      to_user: recipient,
      kind: "request_employee",
      status: "pending")
    request.headers.merge!(other_user.create_new_auth_token)

    put :answer_request_employee, params: { id: notification.id, status: "approved" }, format: :json

    expect(response).to have_http_status(:not_found)
    expect(notification.reload.status).to eq("pending")
  end

  it "rejects unsupported employee request responses without changing the request" do
    recipient = create(:user, email: "response-recipient@example.com", national_id: "response-recipient")
    employee = create(:employee)
    notification = create(:notification,
      from_user: employee.user,
      from_employee: employee,
      to_user: recipient,
      kind: "request_employee",
      status: "pending")
    request.headers.merge!(recipient.create_new_auth_token)

    put :answer_request_employee, params: { id: notification.id, status: "disabled" }, format: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(notification.reload.status).to eq("pending")
  end

  it "does not close an employee request when membership creation fails" do
    recipient = create(:user, email: "failed-response@example.com", national_id: "failed-response")
    employee = create(:employee, role: "partner", status: "approved")
    notification = create(:notification,
      from_user: employee.user,
      from_employee: employee,
      to_user: recipient,
      kind: "request_employee",
      status: "pending")
    request.headers.merge!(recipient.create_new_auth_token)
    invalid_membership = Employee.new
    invalid_membership.errors.add(:status, "is invalid")
    allow(controller).to receive(:create_employe).and_return(invalid_membership)
    allow(invalid_membership).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(invalid_membership))

    expect do
      put :answer_request_employee, params: { id: notification.id, status: "approved" }, format: :json
    end.not_to change(Employee, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(notification.reload.status).to eq("pending")
  end

  it "rejects approval after the requesting partner is disabled" do
    recipient = create(:user, email: "stale-request-recipient@example.com", national_id: "stale-request-recipient")
    partner = create(:employee, role: "partner", status: "approved")
    notification = create(:notification,
      from_user: partner.user,
      from_employee: partner,
      to_user: recipient,
      kind: "request_employee",
      status: "pending")
    partner.update!(status: "disabled")
    request.headers.merge!(recipient.create_new_auth_token)

    expect do
      put :answer_request_employee, params: { id: notification.id, status: "approved" }, format: :json
    end.not_to change(Employee, :count)

    expect(response).to have_http_status(:forbidden)
    expect(notification.reload.status).to eq("pending")
  end

  it "does not create a second membership when an approval is replayed" do
    recipient = create(:user, email: "replayed-request-recipient@example.com", national_id: "replayed-request-recipient")
    partner = create(:employee, role: "partner", status: "approved")
    notification = create(:notification,
      from_user: partner.user,
      from_employee: partner,
      to_user: recipient,
      kind: "request_employee",
      status: "pending")
    request.headers.merge!(recipient.create_new_auth_token)

    expect do
      put :answer_request_employee, params: { id: notification.id, status: "approved" }, format: :json
    end.to change(Employee, :count).by(1)
    expect(response).to have_http_status(:created)

    expect do
      put :answer_request_employee, params: { id: notification.id, status: "approved" }, format: :json
    end.not_to change(Employee, :count)

    expect(response).to have_http_status(:conflict)
  end

  it "does not create duplicate memberships from invitations by different partners" do
    recipient = create(:user, email: "multi-invite-recipient@example.com", national_id: "multi-invite-recipient")
    company = create(:company)
    partners = 2.times.map do |index|
      partner_user = create(:user,
        email: "multi-invite-partner-#{index}@example.com",
        national_id: "multi-invite-partner-#{index}")
      create(:employee, user: partner_user, company: company, role: "partner", status: "approved")
    end
    notifications = partners.map do |partner|
      create(:notification,
        from_user: partner.user,
        from_employee: partner,
        to_user: recipient,
        kind: "request_employee",
        status: "pending")
    end
    request.headers.merge!(recipient.create_new_auth_token)

    expect do
      put :answer_request_employee, params: { id: notifications.first.id, status: "approved" }, format: :json
    end.to change(Employee, :count).by(1)
    expect(response).to have_http_status(:created)

    expect do
      put :answer_request_employee, params: { id: notifications.second.id, status: "approved" }, format: :json
    end.not_to change(Employee, :count)

    expect(response).to have_http_status(:conflict)
    expect(notifications.second.reload.status).to eq("pending")
  end
end
