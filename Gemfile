source "http://rubygems.org"

gem "rails", "~> 5.1.0"
gem "bcrypt-ruby", require: "bcrypt"
gem "actionpack-page_caching"
gem "active_model_serializers", "~> 0.9.0"
gem "responders"

gem "sqlite3"
gem "mysql2", "~> 0.4.2"
gem "pg"

gem "redis", "~> 3.3.0"
gem "hiredis"
gem "redis-rails"

gem "json"
gem "sass-rails", "~> 5.0"
gem "coffee-rails"
gem "uglifier"
gem "dynamic_form"
gem "jquery-rails"
gem "backbone-on-rails"
gem "sprockets-es6"

gem "gemoji"
gem "b3s_emoticons", git: "https://github.com/b3s/b3s_emoticons.git"

# gem 'dynamic_image', '~> 2.0.0.beta5
gem "fog-aws"
gem "dynamic_image"
gem "sentry-raven"

# Deploy with Capistrano
group :development do
  gem "capistrano", "~> 3.8.0"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rbenv"
end

# To use debugger
# gem 'ruby-debug'

# OAuth
gem "doorkeeper" # , '~> 0.7.2'

gem "acts_as_list"

gem "nokogiri"
gem "daemon-spawn"
gem "httparty", "~> 0.15.0"

gem "sunspot_rails", "~> 2.2.0"
gem "progress_bar"

gem "newrelic_rpm", group: "newrelic"

gem "fastimage"
gem "ruby-filemagic", require: "filemagic"
gem "redcarpet", "~> 3.0"
gem "rouge"
gem "font-awesome-rails", "~> 4.7"

# TODO: Remove this when the redesign is done
gem "non-stupid-digest-assets"
gem "activemodel-serializers-xml"

group :development do
  gem "yui-compressor", require: "yui/compressor"
  gem "web-console"
end

group :development_mac do
  gem "rb-fsevent"
  gem "ruby_gntp"
end

group :test do
  gem "codeclimate-test-reporter", require: false
  gem "rails-controller-testing"

  # RSpec
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "json_spec"
  gem "capybara"
  gem "fuubar"
  gem "database_cleaner"
  gem "webmock", require: false
end

group :test, :development do
  gem "puma"
  gem "dotenv-rails", "~> 0.10.0"

  gem "sunspot_solr", "~> 2.1.0"
  gem "sunspot-rails-tester"

  gem "pry"

  # FactoryGirl
  gem "factory_girl_rails"
end
