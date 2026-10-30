require 'devise/orm/active_record'

Devise.setup do |config|

  config.mailer_sender = 'Cuper Club <noreply@cuperclub.com>'
  config.navigational_formats = ["*/*", :html, :json]

  config.scoped_views = true
end
