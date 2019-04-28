module ControllerMacros

  def login_as(user)
    sign_in user
    request.headers.merge!(user.create_new_auth_token)
  end

end
