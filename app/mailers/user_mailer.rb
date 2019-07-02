class UserMailer < ApplicationMailer
  default from: 'Cuper Club <noreply@cuperclub.com>'

  def notify_password_change(user, password, email_to_notify)
    @user= user
    @password= password
    mail(to: email_to_notify, subject: "Contraseña Actualizada")
  end

end
