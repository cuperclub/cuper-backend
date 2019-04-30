class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  private
  def record_not_found(error)
    render json: { error: error.message }, status: :not_found
  end
end
