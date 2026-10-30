module Api
  module Partner
    class OfficePolicy < ApplicationPolicy
      def toggle_status?
        user.employees.exists?(company_id: record.company_id, role: "partner", status: "approved")
      end
    end
  end
end
