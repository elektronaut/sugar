source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.0.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3-ruby', :require => 'sqlite3'

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


gem 'mysql'

# OpenID gem. The stock gem is incompatible with Ruby 1.9, this fixes that.
gem 'ruby-openid', :git => 'git://github.com/xxx/ruby-openid.git', :require => 'openid'

gem 'hpricot'
gem 'daemon-spawn', '0.2.0'
gem 'newrelic_rpm'

gem 'delayed_job', '2.0.3'
gem 'thinking-sphinx', :git => 'git://github.com/freelancing-god/thinking-sphinx.git', :branch  => 'rails3', :require => 'thinking_sphinx'
gem 'ts-delayed-delta', '1.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'

if RUBY_VERSION =~ /^1\.8/
	# Ruby 1.8 version of Ultraviolet
	gem 'ultraviolet', :require => 'uv', :platforms => :ruby_18
else
	# Ruby 1.9 version of Ultraviolet
	gem 'spox-plist', :platforms => :ruby_19
	gem 'spox-textpow', :platforms => :ruby_19
	gem 'spox-ultraviolet', :require => 'uv', :platforms => :ruby_19
end

group :development do
	gem 'juicer'
end

group :test do
	gem 'shoulda'
	gem 'factory_girl_rails'
end
