# encoding: utf-8

require File.expand_path("../boot", __FILE__)
require File.expand_path("../../app/themes/theme", __FILE__)

require "rails/all"

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
  Bundler.require([Rails.env, "mac"].join("_")) if RUBY_PLATFORM =~ /darwin/
  if File.exist?(File.join(File.dirname(__FILE__), "newrelic.yml"))
    Bundler.require(:newrelic)
  end
end

module Sugar
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those
    # specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #{config.root}/lib
    )

    # Only load the plugins named here, in the order given
    # (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    # Default is UTC.
    config.time_zone = "UTC"

    # The default locale is :en and all translations from
    # config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path +=
    #   Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included)
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Tag log entries with uuid
    config.log_tags = [:uuid]

    # Enable the asset pipeline
    config.assets.enabled = true
  end
end

require Rails.root.join("lib/sugar.rb")
