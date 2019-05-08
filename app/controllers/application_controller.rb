class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized(error)
    render json: { error: error.message }, status: :unauthorized
  end

  private
  def record_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:national_id])
  end

end
