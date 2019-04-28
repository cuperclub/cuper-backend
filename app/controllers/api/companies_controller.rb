module Api
  class CompaniesController < BaseController
    before_action :find_company,
                  except: [:create]

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
        "/companies",
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
        render :company,
              status: :created,
              locals: { company: company }
      else
        render json: company.errors,
              status: :unprocessable_entity
      end
    end

    api :GET,
        "/companies/:id",
        "Get a company"
    param :id, Integer, required: true
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

    def show
      render :company,
              status: :accepted,
              locals: { company: @company }
    end

    api :PUT,
        "/companies/:id",
        "Edit a company"
    param :id, Integer, required: true
    example %q{
      "company":{
        "business_name":"The Krusty krab 2.",
        "slogan":"My new cool slogan",
      }
    }

    def update
      if @company.update(company_params)
        render :company,
                status: :accepted,
                locals: { company: @company }
      else
        render json: @company.errors,
              status: :unprocessable_entity
      end
    end

    private

    def find_company
      @company = Company.find(params[:id])
    end

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
