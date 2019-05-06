module Api
  class CompaniesController < ::ApplicationController
    respond_to :json

    api :GET,
        "/companies",
        "Get all companies"
    example %q{
      "companies":[{
        "id": 1,
        "business_name":"The Krusty krab.",
        "logo":null,
      }]
    }

    def index
      companies = Company.all
      render "api/public_companies",
            status: :created,
            locals: { companies: companies }
    end

  end
end
