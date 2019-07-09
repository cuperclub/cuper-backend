class CompanyMailer < ApplicationMailer
  default from: 'Administration Cuper Club <noreply@cuperclub.com>'

  def notify_company_registered(user, company, email_to_notify)
    @user= user
    @company= company
    mail(to: email_to_notify, subject: "Company Registered")
  end

  def notify_company_approved(user, company, email_to_notify)
    @user= user
    @company= company
    mail(to: email_to_notify, subject: "Company Approved")
  end
end
