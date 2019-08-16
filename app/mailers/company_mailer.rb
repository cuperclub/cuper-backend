class CompanyMailer < ApplicationMailer
  default from: 'Cuper Club <noreply@cuperclub.com>'

  def notify_company_registered(user, company, email_to_notify)
    @user = user
    @company = company
    mail(to: email_to_notify, subject: "Company Registered")
  end

  def notify_company_status_updated(user, company, status, feedback)
    @user = user
    @company = company
    @status = status
    @feedback = feedback
    mail(to: user.email, subject: "Company Inf")
  end

  def invitation_employee_company(email, company)
    @email = email
    @company = company
    mail(to: email, subject: "Employee Invitation")
  end
end
