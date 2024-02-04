# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 7.1.0"

gem "actionpack-page_caching"
# gem "active_model_serializers", "~> 0.10.0"
gem "bcrypt", "~> 3.1.12"
gem "sidekiq"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "pg"
gem "puma"

gem "dalli"
gem "hiredis"
gem "redis", "~> 4.1"

gem "alba"
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "react-rails"
gem "sprockets-rails"
gem "terser"
gem "validate_url"

gem "b3s_emoticons",
    git: "https://github.com/b3s/b3s_emoticons.git",
    branch: :master
gem "gemoji"
gem "ruby-oembed", require: "oembed"

gem "dynamic_image", "~> 2.1"
gem "fog-aws"
gem "solid_queue"

gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"

# To use debugger
# gem 'ruby-debug'

gem "acts_as_list"

gem "httparty", "~> 0.17"
gem "nokogiri"

gem "sunspot_rails", "~> 2.6.0"

gem "newrelic_rpm", group: "newrelic"

gem "fastimage"
gem "redcarpet", "~> 3.5"
gem "rouge"
gem "ruby-filemagic", require: "filemagic"

# Used to generate non-digested assets for inclusion in third-party themes.
gem "non-stupid-digest-assets"

group :development do
  # Deploy with Capistrano
  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rbenv"

  gem "web-console"
  gem "yui-compressor", require: "yui/compressor"
end

group :test do
  gem "codeclimate-test-reporter", require: false
  gem "rails-controller-testing"

  # RSpec
  gem "capybara"
  gem "json_spec"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "shoulda-matchers", [">= 4.3.0", "!= 4.4.0"]
  gem "webmock", require: false
end

group :test, :development do
  gem "dotenv-rails"

  gem "sunspot_solr"

  gem "pry"

  # FactoryBot
  gem "factory_bot_rails"

  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end
