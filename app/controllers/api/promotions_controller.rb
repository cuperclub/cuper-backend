module Api
  class PromotionsController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    api :GET,
    "/api/promotions",
    "Get all promotions"
    def index
      promotions = Promotion.all
      render :promotions,
            locals: { promotions: promotions }
    end

    def show
      promotion = Promotion.find(params[:id])
      render :promotion,
             locals: { promotion: promotion }
    end

  end
end
