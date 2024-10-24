# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 7.1.3"

gem "actionpack-page_caching"
gem "acts_as_list"
gem "alba"
gem "bcrypt", "~> 3.1.12"
gem "bootsnap", ">= 1.1.0", require: false
gem "dalli"
gem "dynamic_image", "~> 2.1"
gem "fastimage"
gem "fog-aws"
gem "httparty", "~> 0.17"
gem "nokogiri"
gem "pg"
gem "puma"
gem "redcarpet", "~> 3.5"
gem "rouge"
gem "ruby-filemagic", require: "filemagic"
gem "ruby-oembed", require: "oembed"
gem "sunspot_rails", "~> 2.6.0"
gem "validate_url"

gem "mission_control-jobs"
gem "solid_queue"

# Frontend
gem "b3s_emoticons",
    git: "https://github.com/b3s/b3s_emoticons.git",
    branch: :master
gem "cssbundling-rails"
gem "gemoji"
gem "jsbundling-rails"
gem "react-rails"
gem "sprockets-rails"
gem "terser"

# Used to generate non-digested assets for inclusion in third-party themes.
gem "non-stupid-digest-assets"

# 3rd party monitoring
gem "newrelic_rpm", group: "newrelic"
gem "sentry-rails"
gem "sentry-ruby"

group :development do
  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rbenv"

  gem "web-console"
end

group :development, :test do
  gem "dotenv-rails"
  gem "pry"

  gem "capybara"
  gem "factory_bot_rails"
  gem "json_spec"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "shoulda-matchers", [">= 4.3.0", "!= 4.4.0"]
  gem "simplecov"
  gem "sunspot_solr"
  gem "webmock", require: false

  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
end
