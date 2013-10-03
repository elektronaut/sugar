source 'http://rubygems.org'

gem 'rails', '4.0.0'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'rails-observers'
gem 'actionpack-page_caching'

gem 'sqlite3'
gem 'mysql2'
gem 'pg'

gem 'redis', '~> 3.0.4'
gem 'hiredis', '~> 0.4.5'

gem 'therubyracer'
gem 'json'
gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails'
gem 'uglifier'
gem 'dynamic_form'
gem 'jquery-rails'
gem 'rails-backbone'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# OAuth
gem 'doorkeeper', '~> 0.7.2'

# OpenID gem. The stock gem is incompatible with Ruby 1.9, this fixes that.
gem 'ruby-openid', require: 'openid'

gem 'acts_as_list'

gem 'hpricot'
gem 'daemon-spawn'

gem 'sunspot_rails'
gem 'progress_bar'

gem 'newrelic_rpm', group: 'newrelic'

gem 'fastimage'
gem 'redcarpet', '~> 3.0'

group :development do
  gem 'yui-compressor', require: 'yui/compressor'
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
end

group :development_mac do
  gem 'rb-fsevent'
  gem 'ruby_gntp'
end

group :test do
  gem 'simplecov', require: false
end

group :test, :development do
  gem 'sunspot_solr'
  gem 'sunspot-rails-tester'

  # RSpec
  gem 'rspec-rails'
  gem 'rspec-redis_helper'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'fuubar'

  # FactoryGirl
  gem 'factory_girl_rails'

  # Spork
  gem 'spork'
end