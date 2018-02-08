require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SuncityHrmBackend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.cache_store = [
      :dalli_store,
      ENV.fetch('MEMCACHED_HOST', '127.0.0.1'),
      { namespace: 'suncity', compress: true }
    ]

    config.active_job.queue_adapter = :sidekiq

    # Convert to Beijing Time when read datetime from ActiveRecord
    config.time_zone = 'Beijing'
    # Save Time as local(Beijing) Time when write datetime into ActiveRecord
    config.active_record.default_timezone = :utc


    config.i18n.default_locale = :'zh-HK'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    ActiveModelSerializers.config.adapter = :json

    config.generators do |g|
      g.test_framework :minitest, spec: false, fixture: :factory_girl
      g.fixture_replacement :factory_girl
    end


  end
end
