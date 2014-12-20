source 'http://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'active_model_serializers', '~> 0.8.0'
gem 'responders', '~> 2.0'

gem 'sqlite3'
gem 'mysql2'
gem 'pg'

gem 'redis', '~> 3.1.0'
gem 'hiredis', '~> 0.5.1'
gem 'redis-rails', '~> 4.0.0'

gem 'json'
gem 'sass-rails', '~> 4.0.0'
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

gem 'sunspot_rails', '~> 2.1.0'
gem 'progress_bar'

gem 'newrelic_rpm', group: 'newrelic'

gem 'fastimage'
gem 'ruby-filemagic', require: 'filemagic'
gem 'aws-sdk'
gem 'redcarpet', '~> 3.0'
gem 'rouge'
gem "font-awesome-rails", "~> 3.2.1"

# TODO: Remove this when the redesign is done
gem "non-stupid-digest-assets"

group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'yui-compressor', require: 'yui/compressor'
  gem 'guard'
  gem 'guard-spring'
  gem 'guard-rspec'
  gem 'web-console', '~> 2.0'
end

group :development_mac do
  gem 'rb-fsevent'
  gem 'ruby_gntp'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
end

group :test, :development do
  gem 'dotenv-rails', '~> 0.10.0'

  gem 'sunspot_solr', '~> 2.1.0'
  gem 'sunspot-rails-tester'

  # RSpec
  gem 'minitest'
  gem 'rspec-rails', '~> 2.14'
  gem 'shoulda-matchers'
  gem 'json_spec'
  gem 'capybara'
  gem 'fuubar'

  # FactoryGirl
  gem 'factory_girl_rails'

end
