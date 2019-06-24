module Api
  class TransactionInputsController < BaseController
    before_action :authenticate_user!

    def index
      transaction_inputs = TransactionInput.where(employee: current_user)
      render :transaction_inputs,
            locals: { transaction_inputs: transaction_inputs }
    end

    def create
      transaction_input_params = params[:transaction_input]
      user = User.find_by(id: transaction_input_params[:user_id])
      transaction_input = TransactionInput.new(user: user,
        employee: current_user.employees.first, #TODO: Change for profile selected
        points: transaction_input_params[:points],
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
  end
end
