module Api
  module Partner
    class PromotionsController < BaseController
      before_action :authenticate_user!,
                    :find_office

      api :GET,
          "/partner/offices/:office_id/promotions",
          "Get all promotions of an specific office"
      example %q{
        "promotions":[{
          "title": 'Hamburguesas 2x1',
          "description": 'Aprovecha esta mega oferta',
          "terms": 'Valido los días Lunes',
          "totalRewards": 10,
          "pointsRequired": 100,
        }]
      }

      def index
        promotions = @office.promotions
        render :promotions,
              status: :created,
              locals: { promotions: promotions }
      end

      def_param_group :promotion do
        param :title, String,
              required: true
        param :description, String,
              required: true
        param :totalRewards, Integer,
              required: true
      end

      api :POST,
          "/partner/offices/:office_id/promotions",
          "Submit a promotion into an specific office. Response includes the errors if any."
      param_group :promotion
      example %q{
        "promotion":{
          "title": 'Pizzas Familiares',
          "description": 'Aprovecha este oferton',
          "terms": 'Valido los días Jueves',
          "totalRewards": 10,
          "pointsRequired": 100,
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
          "totalRewards": 10,
          "pointsRequired": 100,
        }
      }

      def show
        promotion = @office.promotions.find(params[:id])
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
          "totalRewards": 20,
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
          :totalRewards,
          :pointsRequired,
          :startAt,
          :endAt,
          :office_id
        )
      end

      def find_office
        @office = current_user.company.offices.find(params[:office_id])
      end
    end
  end
end

