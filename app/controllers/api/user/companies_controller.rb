module Api
  module User
    class CompaniesController < BaseController

      def_param_group :user_company do
        param :ruc, String, required: true
        param :business_name, String,
              required: true,
              desc: "AKA. Comercial name"
        param :slogan, String
        param :economic_activity, String
        param :contributor_type, String
        param :legal_representative, String,
              required: true,
              desc: "Owner's company"
        param :logo, File, required: false
      end

      api :POST,
          "/user/companies",
          "Submit a company application. Response includes the errors if any."
      param_group :user_company
      example %q{
        "company":{
          "ruc":"5184135690",
          "business_name":"The Krusty krab.",
          "contributor_type":"Natural",
          "economic_activity":"Restaurant",
          "legal_representative":"Mr. Krabs",
          "logo":null,
          "slogan":"a cool slogan",
        }
      }

      def create
        company = Company.new(company_params)
        if company.save
          render json: company,
                status: :created
        else
          render json: company.errors,
                status: :unprocessable_entity
        end
      end

      def show
        company = Company.find(params[:id])
        if company
          render json: company,
                status: :accepted
        else
          render json: nil,
                status: :not_found
        end
      end

      private

      def company_params
        params.require(:company).permit(
          :ruc,
          :business_name,
          :contributor_type,
          :economic_activity,
          :legal_representative,
          :logo,
          :slogan
        )
      end
    end
  end
end
