module Api
  class PromotionsController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    api :GET,
    "/api/promotions",
    "Get all promotions"
    def index
      promotions = promotions_availables
      render :promotions,
            locals: { promotions: promotions }
    end

    def show
      promotion = Promotion.find(params[:id])
      render :promotion,
             locals: { promotion: promotion }
    end

    private

    def companies_aproved
      @companiesIds = []
      Employee.where(status: "approved", role: "partner").each do |employee|
        @companiesIds.push(employee.company_id)
      end
      @companiesIds
    end

    def promotions_availables
      @promotions = []
      Promotion.all.each do |promotion|
        if companies_aproved.include?(promotion.office.company_id)
          @promotions.push(promotion)
        end
      end
      @promotions
    end

  end
end
