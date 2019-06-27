module Api
  class TransactionOutputsController < BaseController
    before_action :authenticate_user!

    def index
      transaction_outputs = TransactionOutput.where(employee: current_user)
      render :transaction_outputs,
            locals: { transaction_outputs: transaction_outputs }
    end

    def create
      transaction_output_params = params[:transaction_output]
      user = User.find_by(id: transaction_output_params[:user_id])
      transaction_output = TransactionOutput.new(user: user,
        employee: current_user.employees.first, #TODO: Change for profile selected
        points: transaction_output_params[:points],
        promotion_id: transaction_output_params[:promotion_id],
        invoice_number: transaction_output_params[:invoice_number])
      if transaction_output.save
        render :transaction_output,
          status: :created,
          locals: { transaction_output: transaction_output }
        else
          render json: transaction_output.errors,
          status: :unprocessable_entity
        end
    end
  end
end
