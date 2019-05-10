require "pry"
module Auth
  class PasswordsController < DeviseTokenAuth::PasswordsController
    extend BaseDoc

    resource_description do
      name "Auth::Passwords"
      short "password reset"
      description "password recovery functionality handled by [`devise_token_auth` gem](https://github.com/lynndylanhurley/devise_token_auth)"
    end

    doc_for :create do
      api :POST,
          "/auth/password",
          "reset password providing email"
      param :email, String, required: true
      param :redirect_url, String, required: true
    end

    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      if successfully_sent?(resource)
        render json: {status: 'ok'}, status: :ok
      else
        render json: {error: ['Error occurred']}, status: :internal_server_error
      end
    end

    doc_for :edit do
      api :GET,
          "/auth/password/edit",
          "verify user by password reset token"
      description "this is the URL generated in the reset password feature. will allow user to update password"
      param :redirect_url, String, required: true
      param :reset_password_token, String, required: true
    end

    doc_for :update do
      api :PUT,
          "/auth/password",
          "update account's password"
      param :password, String, required: true
      param :password_confirmation, String, required: true
    end
  end
end
