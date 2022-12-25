# frozen_string_literal: true

class Configuration
  class InvalidConfigurationKey < StandardError; end

  include ActiveModel::Model

  Setting = Struct.new(:type, :default)

  class << self
    def settings
      @settings ||= {}
    end

    def setting(key, type, default = nil)
      settings[key] = Setting.new(type, default)
      define_reader_method(key)
      define_boolean_reader_method(key)
      define_writer_method(key)
    end

    private

    def define_reader_method(key)
      define_method key do |*args|
        args.any? ? set(key, *args) : get(key)
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

  include CustomizationSettings
  include IntegrationSettings
  include ThemeSettings

  def get(key)
    validate_setting(key)
    if configuration.key?(key)
      configuration[key]
    else
      self.class.settings[key].default
    end
  end

  def set(key, value)
    key = key.to_sym if key.is_a?(String)
    validate_setting(key)
    validate_type(key, value)
    value = parse_value(key, value)
    configuration[key] = value
  end

  def load
    saved_config = Sugar.redis.get("configuration")
    return unless saved_config

    @configuration = JSON.parse(saved_config).symbolize_keys
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

  def setting?(key)
    self.class.settings.key?(key)
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

  def validate_setting(key)
    return if setting?(key)

    raise(InvalidConfigurationKey, ":#{key} is not a valid option")
  end

  def validate_type(key, value)
    return if valid_type?(key, parse_value(key, value))

    raise(ArgumentError, "expected #{self.class.settings[key].type}, " \
                         "got #{value.class} (#{value.inspect})")
  end

  def parse_value(key, value)
    if type_for(key) == :boolean
      if ["1", "true", :enabled].include?(value)
        value = true
      elsif ["0", "false", :disabled].include?(value)
        value = false
      end
    end
    value
  end
end
