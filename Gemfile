source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.12'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'base64'
gem 'bigdecimal'
gem 'mutex_m'
gem 'observer'
gem 'drb'
gem 'psych', '< 4'
gem 'json', '< 3'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem 'searchlight'
gem 'pusher', '~> 1.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'pry-rails'
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'database_cleaner-active_record'
end

group :development do
  gem 'listen', '>= 3.0.5'
  gem 'rb-readline'
  gem 'rails-erd'
end

group :staging do
  gem 'cloudinary'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'omniauth', '~> 1.6'
gem 'omniauth-facebook', '~> 9.0'
gem 'omniauth-google-oauth2'

gem 'devise'
gem 'devise_token_auth', '~> 1.2'
gem 'rack-cors', '~> 1.0', require: 'rack/cors'
gem 'apipie-rails'
gem 'carrierwave', '~> 3.1.4'
gem 'kaminari'

gem "pundit"
