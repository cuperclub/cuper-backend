module Api
  module Partner
    class PromotionsController < BaseController
      PAGE = 1
      PER_PAGE = 5

      before_action :authenticate_user!
      before_action :find_office, only: [:create, :update]
      before_action :find_company, only: [:index, :show, :update, :transaction_outputs]

      api :GET,
          "/api/partner/companies/promotions",
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
        promotion_list = @company.promotions
        promotions = promotion_list.page(params[:page] || PAGE)
                      .per(params[:per_page] || PER_PAGE)
        render :promotions,
              status: :created,
              locals: { promotions: promotions, total_count: promotions.total_count }
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
          "/partner/companies/offices/:office_id/promotions",
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

      api :GET,
          "/partner/offices/:office_id/promotions/:id/transaction_outputs",
          "Get all transaction outputs of an specific promotions"
      param :id, Integer, required: true
      def transaction_outputs
        promotion = @company.promotions.find(params[:id])
        transaction_outputs = promotion.transaction_outputs
        render "api/transaction_outputs/transaction_outputs",
          locals: { transaction_outputs: transaction_outputs, total_count: 0 }
      end

      private

      def promotion_params
        params.permit(
          :title,
          :description,
          :terms,
          :total_rewards,
          :points_required,
          :start_at,
          :end_at,
          :image,
          :office_id,
          :unlimited
        )
      end

      def find_office
        company = find_company
        @office = company.offices.find(params[:office_id])
      end

      def find_company
        @company = Company.find(current_user.current_view_company_id)
      end
    end
  end
end
