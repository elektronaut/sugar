ENV["RAILS_ENV"] ||= "test"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "rubygems"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "shoulda-matchers"
require "webmock/rspec"

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: "codeclimate.com"
)

$original_sunspot_session = Sunspot.session
Sunspot::Rails::Tester.start_original_sunspot_session

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| load f }

Sugar.redis = Redis.connect(RedisHelper::CONFIG)

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.use_transactional_examples = false

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Stub Sunspot
  config.before do
    Sunspot.session =
      Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before :each, solr: true do
    Sunspot::Rails::Tester.start_original_sunspot_session
    Sunspot.session = $original_sunspot_session
    Sunspot.remove_all!
  end

  # Use FactoryGirl shorthand
  config.include FactoryGirl::Syntax::Methods

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.infer_spec_type_from_file_location!

  config.include RedisHelper, redis: true
  config.include JsonSpec::Helpers
  config.include LoginMacros, type: :controller
  config.include MailerMacros
  config.include ConfigurationMacros

  config.before(:each) { reset_email }

  # Clean the Redis database and reload the configuration
  config.around(:each, redis: true) do |example|
    with_clean_redis do
      Sugar.config.reset!
      example.run
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
