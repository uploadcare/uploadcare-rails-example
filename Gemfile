# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby ">= 4.0.0"

gem "rails", "~> 8.1.2"
# Use pg as the database for Active Record
gem "pg"
# Use Puma as the app server
gem "puma"

# The asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

gem "turbo-rails"
gem "jsbundling-rails"
gem "tailwindcss-rails", "~> 4.4"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis"

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "brakeman"
  gem "byebug", platforms: %i[mri windows]
  gem "factory_bot_rails"
  gem "rails_best_practices"
  gem "rails-controller-testing"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Env variables setter
  gem "dotenv-rails", require: "dotenv/load"
  gem "foreman"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  # gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

group :test do
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "rspec-rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows mswin jruby]

# Uploadcare-rails provides unified API interface to Uploadcare API
gem "uploadcare-rails", "5.0.0.rc1"
gem "uploadcare-ruby", "5.0.0.rc1"

# Use MongoDB for the database, with Mongoid as the ODM
gem "mongoid", "< 10"
gem "ostruct"
