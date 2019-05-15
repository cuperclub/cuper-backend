module Api
  class TransactionInputsController < BaseController
    before_action :authenticate_user!

    def create
      transaction_input_params = params[:transaction_input]
      user = User.find_by national_id: transaction_input_params[:national_id]
      if user
        if user == current_user
          render json: {errors: 'cannot assign yourself'},
          status: :unprocessable_entity
        else
          transaction_input = TransactionInput.create(user: user,
            employee: current_user.employee,
            points: transaction_input_params[:points],
            invoice_number: transaction_input_params[:invoice_number])
          render(
          :transaction_input,
          status: :created,
          locals: { transaction_input: transaction_input }
          )
        end

      else
        render json: {errors: 'not found'},
        status: :not_found
      end
    end
  end
end
