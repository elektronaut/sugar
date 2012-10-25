source 'http://rubygems.org'
source 'http://gems.github.com'

def mac?
  RUBY_PLATFORM.downcase.include?('darwin')
end

gem 'rails', '3.2.8'
gem "bcrypt-ruby", :require => "bcrypt"

# gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'sqlite3'
gem 'mysql2'
gem 'pg'

gem "redis", "~> 3.0.0.rc2"
gem "hiredis", "~> 0.4.5"

# Asset template engines
gem 'json'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'dynamic_form'

gem 'jquery-rails'
gem 'rails-backbone'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# OpenID gem. The stock gem is incompatible with Ruby 1.9, this fixes that.
gem 'ruby-openid', :git => 'git://github.com/xxx/ruby-openid.git', :require => 'openid'

gem 'acts_as_list'

gem 'hpricot', '0.8.4'
gem 'daemon-spawn', '0.2.0'

gem 'sunspot_rails'
gem 'progress_bar'

#gem 'delayed_job', '2.1.4'

group :production do
  gem 'newrelic_rpm'
end

group :development do
  gem 'yui-compressor', :require => 'yui/compressor'

  # Guard
  gem 'rb-fsevent' #if mac?
  gem 'ruby_gntp' #if mac?
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
end

group :test do
  gem 'simplecov', :require => false
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