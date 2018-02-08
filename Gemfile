if ENV['USE_ALI_GEM_SOURCE']
  source 'http://mirrors.aliyun.com/rubygems/'
else
  source 'https://rubygems.org/'
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
gem 'pg'
gem 'puma', '~> 3.0'

gem 'bcrypt', '~> 3.1.7'
gem 'jwt'
gem 'dalli'
gem 'activerecord-precount'
gem 'aasm'

gem 'kaminari'
gem 'rack-cors'
gem 'awesome_nested_set'
gem 'closure_tree'

gem 'rswag'

# Serializer
gem 'active_model_serializers'

# Define attributes with optional information about types, reader/writer method visibility
gem 'virtus'

# SQL server
# You may need to run `sudo apt-get install freetds-dev` first
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter'

# gem 'axlsx_rails'
gem 'axlsx', '~> 2.1.0.pre'

gem 'rest-client'
gem 'seaweedrb'

gem 'sidekiq'
gem "sidekiq-cron"

gem 'annotate'

# doc template
gem 'sablon'

# twilio sms
gem 'twilio-ruby', '~> 4.11.1'

# Authorization
gem 'pundit'

gem 'exception_notification'

# LDAP
gem 'net-ldap'

# import excel
gem "roo", "~> 2.7.0"

# import goldiloader solve n+1
gem "goldiloader"

# crontab
gem 'whenever', :require => false

# for dancing link
gem 'backports'

# for debug only
gem "better_errors"
gem "binding_of_caller"

# debtaku calculator
gem 'dentaku', '~> 2.0', '>= 2.0.5'

group :development, :test do
  gem 'rspec-rails'
  gem 'minitest-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'pry'
  gem 'dotenv-rails'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'webmock'
  gem 'mocha'
  gem "better_errors"
  gem "binding_of_caller"
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "rails-erd"
end

group :test do
  gem 'whenever-test'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
