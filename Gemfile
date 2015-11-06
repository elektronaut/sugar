source 'http://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'active_model_serializers', '~> 0.9.0'
gem 'responders', '~> 2.1.0'

gem 'sqlite3'
gem 'mysql2', '~> 0.3.20'
gem 'pg'

gem 'redis', '~> 3.2.0'
gem 'hiredis', '~> 0.6.0'
gem 'redis-rails', '~> 4.0.0'

gem 'json'
gem 'sass-rails', '~> 5.0.0'
gem 'coffee-rails'
gem 'uglifier'
gem 'dynamic_form'
gem 'jquery-rails'
gem 'backbone-on-rails'

gem 'gemoji', git: "https://github.com/github/gemoji.git"
gem 'b3s_emoticons', git: "https://github.com/elektronaut/b3s_emoticons.git"

#gem 'dynamic_image', '~> 2.0.0.beta5
gem 'dynamic_image', git: 'https://github.com/elektronaut/dynamic_image.git'

# Deploy with Capistrano
group :development do
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
end

# To use debugger
# gem 'ruby-debug'

# OAuth
gem 'doorkeeper'#, '~> 0.7.2'

# OpenID gem. The stock gem is incompatible with Ruby 1.9, this fixes that.
gem 'ruby-openid', require: 'openid'

gem 'acts_as_list'

gem 'nokogiri'
gem 'daemon-spawn'
gem 'httparty', '~> 0.13.5'

gem 'sunspot_rails', '~> 2.2.0'
gem 'progress_bar'

gem 'newrelic_rpm', group: 'newrelic'

gem 'fastimage'
gem 'ruby-filemagic', require: 'filemagic'
gem 'redcarpet', '~> 3.0'
gem 'rouge'
gem "font-awesome-rails", "~> 3.2.1"

# TODO: Remove this when the redesign is done
gem "non-stupid-digest-assets"

group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'yui-compressor', require: 'yui/compressor'
  gem 'web-console', '~> 2.1.0'
  gem 'hound-tools', '~> 0.0.4', require: false
end

group :development_mac do
  gem 'rb-fsevent'
  gem 'ruby_gntp'
end

group :test do
  gem 'codeclimate-test-reporter', require: false

  # RSpec
  gem 'rspec-rails', '~> 3.1.0'
  gem 'shoulda-matchers', '~> 2.7.0'
  gem 'json_spec'
  gem 'capybara'
  gem 'fuubar'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'webmock', require: false
end

group :test, :development do
  gem 'dotenv-rails', '~> 0.10.0'

  gem 'sunspot_solr', '~> 2.1.0'
  gem 'sunspot-rails-tester'

  gem 'pry'

  # FactoryGirl
  gem 'factory_girl_rails'
end
