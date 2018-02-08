Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end

FRONTEND_URL = ENV["FRONTEND_URL"]
Rails.application.config.action_cable.allowed_request_origins = [FRONTEND_URL]

# SeaweedFS
SEAWEED_HOST = ENV["SEAWEED_HOST"]
SEAWEED_WRITE_PORT = ENV["SEAWEED_WRITE_PORT"]
SEAWEED_READ_PORT = ENV["SEAWEED_READ_PORT"]

HR_LDAP_SERVER_HOST = ENV['HR_LDAP_SERVER_HOST']
HR_LDAP_SERVER_PORT = ENV['HR_LDAP_SERVER_PORT']
HR_LDAP_ACCOUNT_DN = ENV['HR_LDAP_ACCOUNT_DN']
HR_LDAP_ACCOUNT_PASS = ENV['HR_LDAP_ACCOUNT_PASS']

# Suncity SMS
SMS_URL = "http://sms.soonest.cc:8080/ssms/send"
SMS_ROOM_ID = "70"
SMS_USER_NAME = "suncity_hr_system"
SMS_PASSWORD = "z3e@wx@87gg"

# LDAP
HR_LDAP_SERVER_HOST = ENV['HR_LDAP_SERVER_HOST']
HR_LDAP_SERVER_PORT = ENV['HR_LDAP_SERVER_PORT']
HR_LDAP_ACCOUNT_DN = ENV['HR_LDAP_ACCOUNT_DN']
HR_LDAP_ACCOUNT_PASS = ENV['HR_LDAP_ACCOUNT_PASS']

# Default Test Password
TEST_PASSWORD = "123456"

# Twillio SMS
Twilio.configure do |config|
  config.account_sid = ENV["TWILIO_ACCOUNT_SID"]
  config.auth_token = ENV["TWILIO_AUTH_TOKEN"]
end
TWILIO_FROM = ENV["TWILIO_FROM"]

