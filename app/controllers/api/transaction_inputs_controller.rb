module Api
  class TransactionInputsController < BaseController
    before_action :authenticate_user!

    def create
      transaction_input_params = params[:transaction_input]
      user = User.find_by national_id: transaction_input_params[:national_id]
      transaction_input = TransactionInput.new(user: user,
        employee: current_user.employee,
        points: transaction_input_params[:points],
        invoice_number: transaction_input_params[:invoice_number])
      if transaction_input.save
        render(
        :transaction_input,
        status: :created,
        locals: { transaction_input: transaction_input }
        )
        else
          render json: transaction_input.errors,
          status: :unprocessable_entity
        end
    end
  end
end
