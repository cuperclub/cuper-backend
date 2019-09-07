Devise.setup do |config|

  config.navigational_formats = ["*/*", :html, :json]

  config.scoped_views = true
  config.omniauth :facebook, Rails.application.credentials[Rails.env.to_sym][:facebook_app_id], Rails.application.credentials[Rails.env.to_sym][:facebook_app_secret], scope: 'email'
end
