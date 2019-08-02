module Auth
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    before_action :force_json

    protected

    def render_create_success
      add_points_by_register!
      @success = true
      render "api/auth/sessions/user"
    end

    private

    def force_json
      request.format = :json
    end

    def add_points_by_register!
      UtilService.new(current_user).assign_promo_points
    end
  end
end
