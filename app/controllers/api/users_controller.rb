module Api
  class UsersController < BaseController

    before_action :authenticate_user!
    PAGE = 1
    PER_PAGE = 5

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

    api :GET,
    "/users/my_transactions",
    "returns current user transactions"

    def my_transactions
      inputs = TransactionInput.where(user: current_user)
      outputs = TransactionOutput.where(user: current_user)
      user_transactions = inputs + outputs
      all_transactions = paginate_transactions(user_transactions)
      render "api/all_transactions",
        status: :ok,
        locals: { transactions: all_transactions, total_count: all_transactions.total_count }
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
        expired_plan = validate_plan(record.current_company)
        render json: {
          company_id: record.current_company,
          expired_plan: expired_plan
          }, status: :ok
      else
        render json: record.errors,
              status: :unprocessable_entity
      end
    end

    def validate_plan(company_id)
      current_plan = PlanCompany.find_by_company_id(company_id)
      if current_plan
        day_in_seconds = 86400
        expired_date = current_plan.start_date + (current_plan.plan.days * day_in_seconds)
        expired_plan = expired_date < DateTime.now
        if expired_plan && !current_plan.expired
          current_plan.expired = true
          current_plan.save
          employee = Employee.where(company: company_id, user: current_user).first
          employee.status = "expired"
          employee.save
        end
      end
      expired_plan
    end

    def paginate_transactions(transactions_data)
      sorted_transactions = sort_transactions(transactions_data)
      Kaminari.paginate_array(sorted_transactions)
              .page(params[:page] || PAGE)
              .per(params[:per_page] || PER_PAGE)
    end

    def sort_transactions(transactions_data)
      transactions_data.sort_by {|elem| elem[:created_at]}.reverse
    end

  end
end
