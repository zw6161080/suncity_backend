Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "suncity-hrm-backend_#{Rails.env}"

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
      :enable_starttls_auto => true
  }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end

FRONTEND_URL = ENV["FRONTEND_URL"]
Rails.application.config.action_cable.allowed_request_origins = [FRONTEND_URL]

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
HR_LDAP_SERVER_HOST = ENV["HR_LDAP_SERVER_HOST"]
HR_LDAP_SERVER_PORT = ENV["HR_LDAP_SERVER_PORT"]
HR_LDAP_ACCOUNT_DN = ENV["HR_LDAP_ACCOUNT_DN"]
HR_LDAP_ACCOUNT_PASS = ENV["HR_LDAP_ACCOUNT_PASS"]

# Default Test Password
TEST_PASSWORD = "123456"
