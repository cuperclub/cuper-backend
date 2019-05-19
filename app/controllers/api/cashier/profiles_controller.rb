module Api
  module Cashier
    class ProfilesController < BaseController
      before_action :authenticate_user!
      before_action :find_company, only: [:create]

      def_param_group :request do
        param :company_id, Integer,
              required: true
      end

      api :POST,
          "/cashier/profile",
          "Submit a cashier application. Response includes the errors if any."
      param_group :request

      def create
        cashier = Employee.new(
          user: current_user,
          company: @company,
          role: 'cashier'
        )
        if cashier.save
          render json: {status: :accepted},
                 status: :accepted
        else
          render json: cashier.errors,
                status: :unprocessable_entity
        end
      end

      private

      def find_company
        @company = Company.find(params[:company_id])
      end
    end
  end
end
