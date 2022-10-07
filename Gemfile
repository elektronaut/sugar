# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 7.0.0"

gem "actionpack-page_caching"
# gem "active_model_serializers", "~> 0.10.0"
gem "bcrypt", "~> 3.1.12"
gem "fast_jsonapi"
gem "sidekiq"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "pg"
gem "puma"

gem "dalli"
gem "hiredis"
gem "redis", "~> 4.1"

gem "dynamic_form"
gem "jsbundling-rails"
gem "json"
gem "sass-rails", ">= 6.0"
gem "terser"
gem "validate_url"

gem "b3s_emoticons",
    git: "https://github.com/b3s/b3s_emoticons.git",
    branch: :master
gem "gemoji"
gem "ruby-oembed", require: "oembed"

# gem 'dynamic_image', '~> 2.0.0.beta5
gem "dynamic_image", "~> 2.1"
gem "fog-aws"

gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"

# Ruby 3.1 compatibility, remove when mail gem is updated
# gem "net-imap", require: false
# gem "net-pop", require: false
# gem "net-smtp", require: false

# Deploy with Capistrano
group :development do
  gem "capistrano"#{}, "~> 3.11.0"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rbenv"
end

# To use debugger
# gem 'ruby-debug'

# OAuth
gem "doorkeeper" # , '~> 0.7.2'

gem "acts_as_list"

gem "daemon-spawn"
gem "httparty", "~> 0.17"
gem "nokogiri"

gem "progress_bar"
gem "sunspot_rails", "~> 2.5.0"

gem "newrelic_rpm", group: "newrelic"

gem "fastimage"
gem "font-awesome-rails", "~> 4.7"
gem "redcarpet", "~> 3.5"
gem "rouge"
gem "ruby-filemagic", require: "filemagic"

# TODO: Remove this when the redesign is done
gem "activemodel-serializers-xml"
gem "non-stupid-digest-assets"

group :development do
  gem "web-console"
  gem "yui-compressor", require: "yui/compressor"
end

group :test do
  gem "codeclimate-test-reporter", require: false
  gem "rails-controller-testing"

  # RSpec
  gem "capybara"
  gem "database_cleaner"
  gem "fuubar"
  gem "json_spec"
  gem "rspec-rails"
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
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end
