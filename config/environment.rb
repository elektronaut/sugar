# Be sure to restart your server when you modify this file

require 'yaml'

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Create a random session key if the file doesn't exist
if !File.exist?(File.join(File.dirname(__FILE__), 'session_key')) && ENV['RAILS_ENV'] != "production"
    session_key = ''
    seed = [0..9,'a'..'z','A'..'Z'].map(&:to_a).flatten.map(&:to_s)
    128.times{ session_key += seed[rand(seed.length)] }
    File.open(File.join(File.dirname(__FILE__), 'session_key'), "w"){ |fh| fh.write(session_key)}
end

Rails::Initializer.run do |config|
	# Only load the plugins named here, in the order given. By default, all plugins 
	# in vendor/plugins are loaded in alphabetical order.
	# :all can be used as a placeholder for all plugins not explicitly named
	# config.plugins = [ :exception_notification, :ssl_requirement, :all ]

	# Add additional load paths for your own custom dirs
	# config.load_paths += %W( #{RAILS_ROOT}/extras )

	# Force all environments to use the same logger level
	# (by default production uses :info, the others :debug)
	# config.log_level = :debug

	# Make Time.zone default to the specified zone, and make Active Record store time values
	# in the database in UTC, and return them converted to the specified local zone.
	# Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
	config.time_zone = 'UTC'

	# Use the database for sessions instead of the cookie-based default,
	# which shouldn't be used to store highly confidential information
	# (create the session table with "rake db:sessions:create")
	# config.action_controller.session_store = :active_record_store

	# Use SQL instead of Active Record's schema dumper when creating the test database.
	# This is necessary if your schema can't be completely dumped by the schema dumper,
	# like if you have constraints or database-specific column types
	# config.active_record.schema_format = :sql

	# Activate observers that should always be running
	config.active_record.observers = :post_observer
end
