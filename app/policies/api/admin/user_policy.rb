module Api
  module Admin
    class UserPolicy < ApplicationPolicy
      def admin?
        user.is_admin
      end

      def index?
        admin?
      end
    end
  end
end
