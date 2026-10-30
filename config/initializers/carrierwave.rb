CarrierWave.configure do |config|
  config.asset_host = Rails.application.config_for(:secrets)[:url]
end
