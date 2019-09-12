# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
            Rails.application.credentials[Rails.env.to_sym][:facebook_app_id],
            Rails.application.credentials[Rails.env.to_sym][:facebook_app_secret],
            scope: "public_profile,email,user_birthday"
end
