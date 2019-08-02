module Api
  module Admin
    class AppSettingsController < BaseController
      before_action :authenticate_user!

      api :GET,
          "/admin/app_settings/settings",
          "Get settings"
      example %q{
        "app_settings":{
          "name":"My Plan",
          "price":"2"
        }
      }

      def settings
        render :app_setting,
                status: :accepted,
                locals: { app_setting: AppSetting.last }
      end

      # api :PUT,
      #     "/admin/plans/:id",
      #     "Edit a plan"
      # param :id, Integer, required: true
      # example %q{
      #   "plan":{
      #     "name":"Food",
      #     "price":"2"
      #   }
      # }
      #
      # def update
      #   if @plan.update(plan_params)
      #     render :plan,
      #             status: :accepted,
      #             locals: { plan: @plan }
      #   else
      #     render json: @plan.errors,
      #           status: :unprocessable_entity
      #   end
      # end
    end
  end
end
