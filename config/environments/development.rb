Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.action_cable.disable_request_forgery_protection = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  config.action_mailer.perform_deliveries = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => ENV["EMAIL_SMTP_ADDRESS"],
    :port => ENV["EMAIL_SMTP_PORT"],
    :domain => ENV["EMAIL_SMTP_DOMAIN"],
    :user_name => ENV["EMAIL_SMTP_USERNAME"],
    :password => ENV["EMAIL_SMTP_PASSWORD"],
    :authentication => 'plain',
    :enable_starttls_auto => true,
    :openssl_verify_mode  => 'none'
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.middleware.use ExceptionNotification::Rack, :simple => {}
end

FRONTEND_URL = ENV["FRONTEND_URL"]
Rails.application.config.action_cable.allowed_request_origins = [FRONTEND_URL, "http://localhost:8080", "http://localhost:8989"]

# SeaweedFS
SEAWEED_HOST = ENV["SEAWEED_HOST"]
SEAWEED_WRITE_PORT = ENV["SEAWEED_WRITE_PORT"]
SEAWEED_READ_PORT = ENV["SEAWEED_READ_PORT"]

# Suncity SMS
SMS_URL = "http://sms.soonest.cc:8080/ssms/send"
SMS_ROOM_ID = "70"
SMS_USER_NAME = "suncity_hr_system"
SMS_PASSWORD = "z3e@wx@87gg"

# Twilio SMS
Twilio.configure do |config|
  config.account_sid = ENV["TWILIO_ACCOUNT_SID"]
  config.auth_token = ENV["TWILIO_AUTH_TOKEN"]
end
TWILIO_FROM = ENV["TWILIO_FROM"]

# LDAP
HR_LDAP_SERVER_HOST = ENV['HR_LDAP_SERVER_HOST']
HR_LDAP_SERVER_PORT = ENV['HR_LDAP_SERVER_PORT']
HR_LDAP_ACCOUNT_DN = ENV['HR_LDAP_ACCOUNT_DN']
HR_LDAP_ACCOUNT_PASS = ENV['HR_LDAP_ACCOUNT_PASS']

# Default Test Password
TEST_PASSWORD = "123456"
