source 'http://rubygems.org'

gem 'rails', '4.0.0.rc1'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'rails-observers'

gem 'sqlite3'
gem 'mysql2'
gem 'pg'

gem 'redis', '~> 3.0.0.rc2'
gem 'hiredis', '~> 0.4.5'

gem 'json'
gem 'sass-rails', '~> 4.0.0.rc1'
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
#gem 'doorkeeper', '~> 0.6.3'
gem 'doorkeeper', git: 'git://github.com/applicake/doorkeeper.git'

# OpenID gem. The stock gem is incompatible with Ruby 1.9, this fixes that.
gem 'ruby-openid', :git => 'git://github.com/xxx/ruby-openid.git', :require => 'openid'

gem 'acts_as_list'

gem 'hpricot', '0.8.4'
gem 'daemon-spawn', '0.2.0'

gem 'sunspot_rails'
gem 'progress_bar'

gem 'newrelic_rpm', :group => 'newrelic'

group :development do
  gem 'yui-compressor', :require => 'yui/compressor'
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
end

group :development_mac do
  gem 'rb-fsevent'
  gem 'ruby_gntp'
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