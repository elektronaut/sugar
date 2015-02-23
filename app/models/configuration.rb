class Configuration
  class InvalidConfigurationKey < StandardError; end

  include ActiveModel::Model

  class << self
    def settings
      @settings ||= {}
    end

    def setting(key, type, default = nil)
      settings[key] = OpenStruct.new(type: type, default: default)
      define_reader_method(key)
      define_boolean_reader_method(key)
      define_writer_method(key)
    end

    private

    def define_reader_method(key)
      define_method key do |*args|
        if args.length > 0
          set(key, *args)
        else
          get(key)
        end
      end
    end

    def define_boolean_reader_method(key)
      define_method "#{key}?" do
        get(key) ? true : false
      end
    end

    def define_writer_method(key)
      define_method "#{key}=" do |value|
        set(key, value)
      end
    end
  end

  module CustomizationSettings
    extend ActiveSupport::Concern
    included do
      setting :forum_name, :string, "Sugar"
      setting :forum_short_name, :string, "Sugar"
      setting :forum_title, :string, "Sugar"
      setting :public_browsing, :boolean, false
      setting :signups_allowed, :boolean, true
      setting :domain_names, :string
      setting :mail_sender, :string

      # Customization
      setting :custom_header, :string
      setting :custom_footer, :string
      setting :custom_javascript, :string
      setting(
        :emoticons,
        :string,
        "smiley laughing blush heart_eyes kissing_heart flushed worried " +
          "grimacing cry angry heart star +1 -1"
        )
    end
  end

  module IntegrationSettings
    extend ActiveSupport::Concern
    included do
      setting :flickr_api, :string
      setting :google_analytics, :string
      setting :amazon_associates_id, :string
      setting :amazon_aws_key, :string
      setting :amazon_aws_secret, :string
      setting :amazon_s3_bucket, :string
      setting :facebook_app_id, :string
      setting :facebook_api_secret, :string
    end
  end

  module ThemeSettings
    extend ActiveSupport::Concern
    included do
      setting :default_theme, :string, "default"
      setting :default_mobile_theme, :string, "default"
    end
  end

  include CustomizationSettings
  include IntegrationSettings
  include ThemeSettings

  def get(key)
    unless has_setting?(key)
      raise(
        InvalidConfigurationKey,
        ":#{key} is not a valid configuration option"
      )
    end
    if configuration.has_key?(key)
      configuration[key]
    else
      self.class.settings[key].default
    end
  end

  def set(key, value)
    key = key.to_sym if key.is_a?(String)
    unless has_setting?(key)
      raise(
        InvalidConfigurationKey,
        ":#{key} is not a valid configuration option"
      )
    end
    value = parse_value(key, value)
    unless valid_type?(key, value)
      raise(
        ArgumentError,
        "expected #{self.class.settings[key].type}, " +
          "got #{value.class} (#{value.inspect})"
      )
    end
    configuration[key] = value
  end

  def load
    if saved_config = Sugar.redis.get("configuration")
      @configuration = JSON.parse(saved_config).symbolize_keys
    end
  end

  def save
    Sugar.redis.set("configuration", @configuration.to_json)
  end

  def update(attributes = {})
    attributes.each { |key, value| set(key, value) }
    save
  end

  def reset!
    @configuration = {}
  end

  protected

  def configuration
    @configuration ||= {}
  end

  def has_setting?(key)
    self.class.settings.has_key?(key)
  end

  def type_for(key)
    self.class.settings[key].type
  end

  def valid_type?(key, value)
    return true if value.nil?
    if type_for(key) == :boolean
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    else
      value.is_a?(type_for(key).to_s.camelize.constantize)
    end
  end

  def parse_value(key, value)
    if type_for(key) == :boolean
      value = true  if value == "1"
      value = false if value == "0"
      value = true  if value == "true"
      value = false if value == "false"
      value = true  if value == :enabled
      value = false if value == :disabled
    end
    value
  end
end
