module Api
  module Admin
    class AppSettingsController < BaseController
      before_action :authenticate_user!

      api :GET,
          "/admin/app_settings/settings",
          "Get settings"
      example %q{
        "app_settings":{
          "points_by_register":"10",
          "main_employee_id":"2",
          "plan_selected_id": 12
          "plans":[{
            "name":"Free",
            "price":"0"
          }]
        }
      }

      def settings
        render :app_setting,
                status: :accepted,
                locals: { app_setting: AppSetting.last }
      end

      api :PUT,
          "/admin/app_settings/:id",
          "Update settings"
      param :id, Integer, required: true
      example %q{
        "app_settings":{
          "points_by_register":"12",
          "main_employee_id":"2",
          "plan_selected_id": 12
        }
      }

      def update_settings
        @appSetting = AppSetting.last;
        if @appSetting.update(app_setting_params)
          render :plan,
                  status: :accepted,
                  locals: { app_setting: @appSetting }
        else
          render json: @appSetting.errors,
                status: :unprocessable_entity
        end
      end

      private

      def app_setting_params
        params.require(:app_setting).permit(
          :points_by_register,
          :main_employee_id,
          :plan_selected_id
        )
      end
    end
  end
end
