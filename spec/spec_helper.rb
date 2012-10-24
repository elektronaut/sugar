require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  unless ENV['DRB']
    require 'simplecov'
  end

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  #require 'sunspot/rails/spec_helper'

  $original_sunspot_session = Sunspot.session
  Sunspot::Rails::Tester.start_original_sunspot_session

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # Stub Sunspot
    config.before do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)
    end
    config.before :each, :solr => true do
      Sunspot::Rails::Tester.start_original_sunspot_session
      Sunspot.session = $original_sunspot_session
      Sunspot.remove_all!
    end

    # Use Redis
    config.include RSpec::RedisHelper, :redis => true
    # Clean the Redis database and reload the configuration
    config.around(:each, :redis => true) do |example|
      with_clean_redis do
        # Reset Redis settings to default
        Sugar.redis = redis
        Sugar.redis_prefix = "sugartest"
        Sugar.reset_config!
        example.run
      end
    end

    # Use FactoryGirl shorthand
    config.include FactoryGirl::Syntax::Methods

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
  end

end

Spork.each_run do

  if ENV['DRB']
    require 'simplecov'
  end

  # This code will be run each time you run your specs.

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| load f}

  RSpec.configure do |config|
    # Macros
    config.include LoginMacros, :type => :controller
    config.include Sugar::Exceptions
  end

end
