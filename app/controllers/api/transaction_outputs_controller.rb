module Api
  class TransactionOutputsController < BaseController
    before_action :authenticate_user!,
                  :find_employee, only: [:index, :create]
    before_action :get_company, only: [:create]

    def index
      transaction_outputs = TransactionOutput.where(employee: @employee).order(created_at: :desc)
      render :transaction_outputs,
            locals: { transaction_outputs: transaction_outputs }
    end

    def create
      transaction_output_params = params[:transaction_output]
      user = User.find_by(id: transaction_output_params[:user_id])
      transaction_output = TransactionOutput.new(user: user,
        employee: @employee,
        points: transaction_output_params[:points],
        promotion_id: transaction_output_params[:promotion_id],
        invoice_number: transaction_output_params[:invoice_number])
      if transaction_output.save
        UtilService.new(user,
                        current_user,
                        {
                          employee: @employee,
                          company: @company,
                          promotion: Promotion.find(transaction_output_params[:promotion_id])
                        }
                      ).notify_client_assign_promotion
        render :transaction_output,
          status: :created,
          locals: { transaction_output: transaction_output }
        else
          render json: transaction_output.errors,
          status: :unprocessable_entity
        end
    end

    private

    def get_company
      @company = Company.find(current_user.current_view_company_id)
    end

    def find_employee
      @employee = Employee.where(company_id: current_user.current_view_company_id,
                                  user: current_user
                                ).first
    end
  end
end
