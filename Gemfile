source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'jquery-rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

gem 'mysql2'

# OpenID gem. The stock gem is incompatible with Ruby 1.9, this fixes that.
gem 'ruby-openid', :git => 'git://github.com/xxx/ruby-openid.git', :require => 'openid'

gem 'hpricot', '0.8.4'
gem 'daemon-spawn', '0.2.0'
gem 'newrelic_rpm', '2.13.4'

gem 'delayed_job', '2.1.4'
gem 'thinking-sphinx', '2.0.7'

# The GitHub version has fixed the deprecation notice, so let's use that for now
#gem 'ts-delayed-delta', '1.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'
#gem 'ts-delayed-delta', :git => 'git://github.com/freelancing-god/ts-delayed-delta.git', :require => 'thinking_sphinx/deltas/delayed_delta'
gem 'ts-delayed-delta', '1.1.2', :require => 'thinking_sphinx/deltas/delayed_delta'

group :development do
  gem 'yui-compressor', :require => 'yui/compressor'
	gem 'guard'
	gem 'guard-test'
	gem 'rb-fsevent'
	gem 'growl_notify'
	gem 'ruby-prof'
end

group :test do
	gem 'shoulda-context'
	gem 'shoulda-matchers'
	gem 'factory_girl_rails'
end