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
    end
  end
end
