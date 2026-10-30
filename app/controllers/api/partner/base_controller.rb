module Api
  module Partner
    class BaseController < Api::BaseController
      private

      def find_partner_company
        current_user.employees
          .where(role: "partner", status: "approved")
          .find_by!(company_id: current_user.current_view_company_id)
          .company
      end
    end
  end
end
