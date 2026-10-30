module Api
  module Admin
    class BaseController < Api::BaseController
      private

      def authorize_admin!
        authorize current_user, :admin?, policy_class: UserPolicy
      end
    end
  end
end
