# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
            Rails.application.credentials[Rails.env.to_sym][:facebook_app_id],
            Rails.application.credentials[Rails.env.to_sym][:facebook_app_secret],
            scope: "public_profile,email,user_birthday"

  provider :google_oauth2,
            Rails.application.credentials[Rails.env.to_sym][:google_app_id],
            Rails.application.credentials[Rails.env.to_sym][:google_app_secret],
            {
              scope: 'userinfo.email, userinfo.profile, http://gdata.youtube.com',
              prompt: 'select_account',
              image_aspect_ratio: 'square',
              image_size: 50
            }
end

