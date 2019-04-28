module Api
  class UsersController < BaseController

    before_action :authenticate_user!

    def index
      users = User.all
      render :users,
            locals: { users: users }
    end

    def new
    end

    def create
    end

    def update
    end

    def edit
    end

    def destroy
    end

    def show
    end
  end
end
