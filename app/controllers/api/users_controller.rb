module Api
  class UsersController < BaseController

    before_action :authenticate_user!

    api :PUT,
        "/api/users",
        "Update my account"
    example %q{
      "user":{
        "email": "admin@example.com",
        "nickname": "admin",
        "name": "Admin User",
        "national_id": "1234567890",
      }
    }

    def index
      users = User.all
      render "api/users",
              locals: { users:  users}
    end

    def update
      if current_user.update(user_params)
        render "api/user",
                status: :accepted,
                locals: { user: current_user }
      else
        render json: current_user.errors,
              status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.permit(
        :email,
        :nickname,
        :name,
        :image,
        :national_id
      )
    end
  end
end
