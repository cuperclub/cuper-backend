module Api
  module Admin
    class UsersController < BaseController

      before_action :authenticate_user!

      def index
        role = params[:role]
        users = role ? User.by_role(role) : User.all
        authorize users, policy_class: UserPolicy
        render :users,
               locals: { users: users }
      end

      api :PUT,
      "/api/admin/users/:id/toggle_status",
      "Change user status"
      param :id, Integer, required: true
      example %q{
        "user":{
          "email": "admin@example.com",
          "nickname": "admin",
          "name": "Admin User",
          "national_id": "1234567890",
          "active": "true
        }
      }

      def toggle_status
        user = User.find(params[:id])
        user.active = !user.active
        if user.save
          render json: {active: user.active}, status: :ok
        else
          render json: user.errors,
                status: :unprocessable_entity
        end
      end

    end
  end
end
