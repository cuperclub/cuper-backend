module Api
  class TransactionOutputsController < BaseController
    before_action :authenticate_user!

    def create
      transaction_output_params = params[:transaction_output]
      user = User.find_by national_id: transaction_output_params[:national_id]
      transaction_output = TransactionOutput.new(user: user,
        employee: current_user.employee,
        points: transaction_output_params[:points],
        promotion_id: transaction_output_params[:promotion_id],
        invoice_number: transaction_output_params[:invoice_number])
      if transaction_output.save
        render(
        :transaction_output,
        status: :created,
        locals: { transaction_output: transaction_output }
        )
        else
          render json: transaction_output.errors,
          status: :unprocessable_entity
        end
    end
  end
end
