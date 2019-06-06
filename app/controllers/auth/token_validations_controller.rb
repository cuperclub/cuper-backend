module Auth
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
    before_action :force_json

    protected

    def render_validate_token_success
      @success = true
      render "api/auth/sessions/user"
    end

    private

    def force_json
      request.format = :json
    end
  end
end
