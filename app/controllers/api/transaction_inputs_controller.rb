module Api
  class TransactionInputsController < BaseController
    before_action :authenticate_user!
    before_action :find_employee, only: [:index, :create]

    def index
      transaction_inputs = TransactionInput.where(employee: @employee).order(created_at: :desc)
      render :transaction_inputs,
            locals: { transaction_inputs: transaction_inputs }
    end

    def create
      transaction_input_params = params[:transaction_input]
      user = User.find_by(id: transaction_input_params[:user_id])
      transaction_input = TransactionInput.new(user: user,
        employee: @employee,
        points: final_points,
        invoice_number: transaction_input_params[:invoice_number])
      if transaction_input.save
        render :transaction_input,
          status: :created,
          locals: { transaction_input: transaction_input }
        else
          render json: transaction_input.errors,
          status: :unprocessable_entity
        end
    end

    private

    def get_points_per_dollar
      company = Company.find(current_user.current_view_company_id)
      company.category.points_per_dollar
    end

    def find_employee
      @employee = Employee.where(company_id: current_user.current_view_company_id,
                                  user: current_user
                                ).first
    end

    def final_points
      transaction_input_params = params[:transaction_input]
      points = transaction_input_params[:points]
      points * get_points_per_dollar
    end
  end
end
