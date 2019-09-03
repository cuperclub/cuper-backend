require 'pusher'

Pusher.key = Rails.application.credentials[Rails.env.to_sym][:pusher_key]
Pusher.secret = Rails.application.credentials[Rails.env.to_sym][:pusher_secret]
Pusher.app_id = Rails.application.credentials[Rails.env.to_sym][:pusher_app_id]
Pusher.cluster = Rails.application.credentials[Rails.env.to_sym][:pusher_cluster]
Pusher.logger = Rails.logger
Pusher.encrypted = true
