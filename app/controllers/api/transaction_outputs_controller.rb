module Api
  class TransactionOutputsController < BaseController
    before_action :authenticate_user!,
                  :find_employee, only: [:index, :create]
    before_action :get_company, only: [:create]

    PAGE = 1
    PER_PAGE = 5

    def index
      transactions_list = TransactionOutput.where(employee: @employee).order(created_at: :desc)
      transaction_outputs = transactions_list.page(params[:page] || PAGE).per(params[:per_page] || PER_PAGE)
      render :transaction_outputs,
            locals: { transaction_outputs: transaction_outputs, total_count: transaction_outputs.total_count }
    end

    def create
      transaction_output_params = params.require(:transaction_output)
      user = transaction_output_params[:user_id] ?
        User.find_by(id: transaction_output_params[:user_id]) :
        User.find_by(national_id: transaction_output_params[:national_id])
      promotion = @company.promotions.find(transaction_output_params[:promotion_id])
      transaction_output, saved = TransactionOutput.redeem(
        user: user,
        employee: @employee,
        promotion: promotion,
        invoice_number: transaction_output_params[:invoice_number]
      )

      if saved
        UtilService.new(user,
                        current_user,
                        {
                          employee: @employee,
                          company: @company,
                          promotion: promotion
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
      @employee = current_user.employees
        .where(company_id: current_user.current_view_company_id, status: "approved")
        .first!
    end
  end
end
