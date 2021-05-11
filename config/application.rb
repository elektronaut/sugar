# frozen_string_literal: true

require_relative "boot"

require File.expand_path("../app/themes/theme", __dir__)
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sugar
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W[#{config.root}/lib]

    # Settings in config/environments/* take precedence over those
    # specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

require Rails.root.join("lib/sugar.rb")
