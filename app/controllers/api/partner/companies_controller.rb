module Api
  module Partner
    class CompaniesController < BaseController

      api :GET,
          "/partner/company",
          "Get my company"
      example %q{
        {
          "ruc":"5184135690",
          "business_name":"The Krusty krab.",
          "contributor_type":"Natural",
          "economic_activity":"Restaurant",
          "legal_representative":"Mr. Krabs",
          "logo":null,
          "slogan":"a cool slogan",
        }
      }

      def show
        current_user = User.first(2).last #TODO: Get current_user
        company = current_user.company
        render :company,
                status: :accepted,
                locals: { company: company }
      end

      api :PUT,
          "/partner/company",
          "Update my company"
      example %q{
        "company":{
          "business_name":"The Krusty krab 2.",
          "slogan":"My new cool slogan",
        }
      }

      def update
        current_user = User.first(2).last #TODO: Get current_user
        company = current_user.company
        if company.update(company_params)
          render :company,
                  status: :accepted,
                  locals: { company: company }
        else
          render json: company.errors,
                status: :unprocessable_entity
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
          :slogan,
          :category_id
        )
      end
    end
  end
end
