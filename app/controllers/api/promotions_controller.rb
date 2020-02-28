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

    def promotions_availables
      @promotions = Promotion.joins(:office).where(offices: {company_id: Company.joins(:employees).select("id").where(employees: {status: "approved", role: "partner"}).map(&:id)})
    end
  end
end

