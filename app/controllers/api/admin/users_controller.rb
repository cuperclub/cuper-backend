module Api
  module Admin
    class UsersController < BaseController
      PAGE = 1
      PER_PAGE = 5

      before_action :authenticate_user!

      def index
        role = params[:role]
        is_role = Employee::ROLES.include?(role)
        users_list = is_role ? User.by_role(role) : User.all
        users = users_list.page(params[:page] || PAGE)
                  .per(params[:per_page] || PER_PAGE)
        authorize users, policy_class: UserPolicy
        render :users,
               locals: { users: users, total_count: users.total_count }
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

      api :PUT,
      "/api/admin/users/:id/update_password",
      "Change user password"
      param :id, Integer, required: true
      def update_password
        user = User.find(params[:id])
        user.password = params[:password]
        if user.save
          UserMailer.notify_password_change(user, params[:password], params[:email]).deliver_now
          render json: {status: :ok}, status: :ok
        else
          render json: user.errors,
                status: :unprocessable_entity
        end
      end
    end
  end
end
