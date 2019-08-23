module Api
  module Admin
    class PlansController < BaseController
      before_action :authenticate_user!,
                    :find_plan,
                    except: [:index, :create]

      api :GET,
          "/admin/plans",
          "Get all plans"
      example %q{
        "plan":[{
          "name":"Free",
          "price":"0"
        }]
      }

      def index
        plans = Plan.all.order(created_at: :desc)
        plans = current_user.companies.count == 0 ? plans : plans.where.not(price: 0.0)
        render :plans,
              status: :created,
              locals: { plans: plans }
      end

      def_param_group :plan do
        param :name, String,
              required: true
        param :price, Integer,
              required: true
        param :days, Integer,
              required: true
      end

      api :POST,
          "/admin/plans",
          "Submit a plan. Response includes the errors if any."
      param_group :plan
      example %q{
        "plan":{
          "name":"Anual",
          "price":"29"
        }
      }

      def create
        plan = Plan.new(plan_params)
        if plan.save
          render :plan,
                status: :created,
                locals: { plan: plan }
        else
          render json: plan.errors,
                status: :unprocessable_entity
        end
      end

      api :GET,
          "/admin/plans/:id",
          "Get a plan"
      param :id, Integer, required: true
      example %q{
        "plan":{
          "name":"My Plan",
          "price":"2"
        }
      }

      def show
        render :plan,
                status: :accepted,
                locals: { plan: @plan }
      end

      api :PUT,
          "/admin/plans/:id",
          "Edit a plan"
      param :id, Integer, required: true
      example %q{
        "plan":{
          "name":"Food",
          "price":"2"
        }
      }

      def update
        if @plan.update(plan_params)
          render :plan,
                  status: :accepted,
                  locals: { plan: @plan }
        else
          render json: @plan.errors,
                status: :unprocessable_entity
        end
      end

      private

      def find_plan
        @plan = Plan.find(params[:id])
      end

      def plan_params
        params.require(:plan).permit(
          :name,
          :price,
          :days,
          :active,
          :information
        )
      end
    end
  end
end
