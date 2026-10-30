# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins 'example.com'
#
#     resource '*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

default_origins = Rails.env.development? || Rails.env.test? ? "http://localhost:4200" : ""
allowed_origins = ENV.fetch("CORS_ALLOWED_ORIGINS", default_origins).split(",").map(&:strip).reject(&:empty?)

raise "CORS_ALLOWED_ORIGINS must not contain '*'" if allowed_origins.include?("*")

Rails.application.config.middleware.use Rack::Cors do
    allow do
      origins(*allowed_origins)
      resource '*',
      :headers => :any,
      :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      :methods => [:get, :post, :options, :delete, :put]
    end
end
