module Api
  module Admin
    class UserPolicy < ApplicationPolicy
      def index?
        user.is_admin
      end
    end
  end
end
