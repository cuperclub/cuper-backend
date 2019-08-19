module Api
  class UsersController < BaseController

    before_action :authenticate_user!

    api :GET,
        "/api/users",
        "Get all clients"
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

    api :GET,
    "/users/search",
    "returns search from query"
    param :page, Integer
    param :query, String

    def search
      users = search_results
      render "api/users",
              locals: { users:  users}
    end


    def current_view
      setting = current_user.setting
      if setting
        setting.current_company = params[:company_id]
        render_setting(setting)
      else
        setting = Setting.new
        setting.current_company = params[:company_id]
        render_setting(setting)
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

    def search_results
      users_results = UserSearch.new( q:params[:query],
                                      id:current_user.id
                                    ).results.limit(10)
    end

    def render_setting(record)
      record.user = current_user
      if record.save
        render json: {company_id: record.current_company}, status: :ok
      else
        render json: record.errors,
              status: :unprocessable_entity
      end
    end

  end
end
