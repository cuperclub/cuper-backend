require "bigdecimal"

module Api
  class TransactionInputsController < BaseController
    before_action :authenticate_user!,
                  :find_employee, only: [:index, :create]
    before_action :get_company, only: [:create]

    PAGE = 1
    PER_PAGE = 5

    def index
      transactions_list = TransactionInput.where(employee: @employee).order(created_at: :desc)
      transaction_inputs = transactions_list.page(params[:page] || PAGE).per(params[:per_page] || PER_PAGE)
      render :transaction_inputs,
            locals: { transaction_inputs: transaction_inputs, total_count: transaction_inputs.total_count }
    end

    def create
      transaction_input_params = params.require(:transaction_input)
      user = transaction_input_params[:user_id] ?
        User.find_by(id: transaction_input_params[:user_id]) :
        User.find_by(national_id: transaction_input_params[:national_id])
      points = final_points
      transaction_input, saved, replayed = TransactionInput.accrue(
        user: user,
        employee: @employee,
        points: points,
        invoice_number: transaction_input_params[:invoice_number],
        idempotency_key: idempotency_key
      )
      if saved
        unless replayed
          UtilService.new(user,
                          current_user,
                          {
                            employee: @employee,
                            company: @company,
                            points: points
                          }
                        ).notify_client_assign_points
        end
        render :transaction_input,
          status: :created,
          locals: { transaction_input: transaction_input }
      else
        render json: transaction_input.errors,
        status: idempotency_conflict?(transaction_input) ? :conflict : :unprocessable_entity
      end
    end

    private

    def find_employee
      @employee = current_user.employees
        .where(company: get_company, status: "approved")
        .first!
    end

    def get_company
      @company = Company.find(current_user.current_view_company_id)
    end

    def get_points_per_dollar
      company = get_company
      company.category.points_per_dollar
    end

    def idempotency_key
      request.headers["Idempotency-Key"]&.strip.presence
    end

    def idempotency_conflict?(record)
      record.errors.details[:base].any? { |error| error[:error] == :idempotency_key_reused }
    end

    def final_points
      transaction_input_params = params[:transaction_input]
      purchase_amount = BigDecimal(transaction_input_params[:points].to_s, exception: false)
      return unless purchase_amount&.finite? && purchase_amount.positive?

      multiplier = get_points_per_dollar
      return unless multiplier.is_a?(Integer)

      result = purchase_amount * multiplier
      return unless result.finite?

      points = result.round(0, half: :up).to_i
      points if points.between?(0, TransactionInput::MAX_SAFE_POINT_VALUE)
    end
  end
end
