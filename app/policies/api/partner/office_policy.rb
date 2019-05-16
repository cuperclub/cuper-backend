module Api
  module Partner
    class OfficePolicy < ApplicationPolicy
      def toggle_status?
        user.is_employee
      end
    end
  end
end
