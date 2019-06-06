module Auth
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    before_action :force_json

    protected

    def render_create_success
      @success = true
      render "api/auth/sessions/user"
    end

    private

    def force_json
      request.format = :json
    end
  end
end
