module Api
  class TransactionInputsController < BaseController
    before_action :authenticate_user!,
                  :find_employee, only: [:index, :create]
    before_action :get_company, only: [:create]

    def index
      transaction_inputs = TransactionInput.where(employee: @employee).order(created_at: :desc)
      render :transaction_inputs,
            locals: { transaction_inputs: transaction_inputs }
    end

    def create
      transaction_input_params = params[:transaction_input]
      user = User.find_by(id: transaction_input_params[:user_id])
      points = final_points
      transaction_input = TransactionInput.new(user: user,
                          employee: @employee,
                          points: points,
                          invoice_number: transaction_input_params[:invoice_number])
      if transaction_input.save
        UtilService.new(user,
                        current_user,
                        {
                          employee: @employee,
                          company: @company,
                          points: points
                        }
                      ).notify_client_assign_points
        render :transaction_input,
          status: :created,
          locals: { transaction_input: transaction_input }
      else
        render json: transaction_input.errors,
        status: :unprocessable_entity
      end
    end

    private

    def find_employee
      @employee = Employee.where(company: get_company,
                                  user: current_user
                                ).first
    end

    def get_company
      @company = Company.find(current_user.current_view_company_id)
    end

    def get_points_per_dollar
      company = get_company
      company.category.points_per_dollar
    end

    def final_points
      transaction_input_params = params[:transaction_input]
      points = transaction_input_params[:points]
      points * get_points_per_dollar
    end
  end
end
