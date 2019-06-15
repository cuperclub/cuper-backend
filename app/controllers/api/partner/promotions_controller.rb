module Api
  module Partner
    class PromotionsController < BaseController
      before_action :authenticate_user!
      before_action :find_office, only: [:create, :update]
      before_action :find_company, only: [:index, :show, :update]

      api :GET,
          "/api/partner/companies/:company_id/promotions",
          "Get all promotions of an specific office"
      example %q{
        "promotions":[{
          "title": 'Hamburguesas 2x1',
          "description": 'Aprovecha esta mega oferta',
          "terms": 'Valido los días Lunes',
          "total_rewards": 10,
          "points_required": 100,
        }]
      }

      def index
        promotions = @company.promotions
        render :promotions,
              status: :created,
              locals: { promotions: promotions }
      end

      def_param_group :promotion do
        param :title, String,
              required: true
        param :description, String,
              required: true
        param :total_rewards, Integer,
              required: true
      end

      api :POST,
          "/partner/companies/:company_id/offices/:office_id/promotions",
          "Submit a promotion into an specific office. Response includes the errors if any."
      param_group :promotion
      example %q{
        "promotion":{
          "title": 'Pizzas Familiares',
          "description": 'Aprovecha este oferton',
          "terms": 'Valido los días Jueves',
          "total_rewards": 10,
          "points_required": 100,
        }
      }

      def create
        promotion = Promotion.new(promotion_params)
        promotion.office = @office
        if promotion.save
          render :promotion,
                status: :created,
                locals: { promotion: promotion }
        else
          render json: promotion.errors,
                status: :unprocessable_entity
        end
      end

      api :GET,
          "/partner/offices/:office_id/promotions/:id",
          "Get a promotion of an specific office"
      param :id, Integer, required: true
      example %q{
        "promotion":{
          "title": 'Pizzas Familiares',
          "description": 'Aprovecha este oferton',
          "terms": 'Valido los días Jueves',
          "total_rewards": 10,
          "points_required": 100,
        }
      }

      def show
        promotion = @company.promotions.find(params[:id])
        render :promotion,
                status: :accepted,
                locals: { promotion: promotion }
      end

      api :PUT,
      "/partner/offices/:office_id/promotions/:id",
      "Edit a promotion of an specific office"
      param :id, Integer, required: true
      example %q{
        "promotion":{
          "title": 'Pizzas Medianas 2x1',
          "description": 'Aprovecha este oferton unico por el día del padre',
          "total_rewards": 20,
        }
      }

      def update
        promotion = @office.promotions.find(params[:id])
        if promotion.update(promotion_params)
          render :promotion,
                  status: :accepted,
                  locals: { promotion: promotion }
        else
          render json: promotion.errors,
                status: :unprocessable_entity
        end
      end

      private

      def promotion_params
        params.require(:promotion).permit(
          :title,
          :description,
          :terms,
          :total_rewards,
          :points_required,
          :start_at,
          :end_at,
          :office_id
        )
      end

      def find_office
        company = find_company
        @office = company.offices.find(params[:office_id])
      end

      def find_company
        @company = current_user.companies.find(params[:company_id])
      end
    end
  end
end
