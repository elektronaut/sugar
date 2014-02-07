# encoding: utf-8

module Sugar
  class Configuration
    class InvalidConfigurationKey < StandardError; end

    class << self
      def settings
        @settings ||= {}
      end

      def setting(key, type, default=nil)
        settings[key] = OpenStruct.new(type: type, default: default)

        define_method key do |*args|
          if args.length > 0
            set(key, *args)
          else
            get(key)
          end
        end

        define_method "#{key}=" do |value|
          set(key, value)
        end

        define_method "#{key}?" do
          get(key) ? true : false
        end
      end
    end

    setting :forum_name,           :string, 'Sugar'
    setting :forum_short_name,     :string, 'Sugar'
    setting :forum_title,          :string, 'Sugar'

    # Hosts etc
    setting :default_domain,       :string
    setting :asset_host,           :string
    setting :mail_sender,          :string
    setting :session_key,          :string, '_sugar_session'

    # Themes
    setting :default_theme,        :string, 'default'
    setting :default_mobile_theme, :string, 'default'

    # Options
    setting :public_browsing,      :boolean, false
    setting :signups_allowed,      :boolean, true

    # Integration
    setting :xbox_live_enabled,    :boolean, false
    setting :flickr_api,           :string
    setting :google_analytics,     :string
    setting :amazon_associates_id, :string
    setting :amazon_aws_key,       :string
    setting :amazon_aws_secret,    :string
    setting :amazon_s3_bucket,     :string

    # Facebook integration
    setting :facebook_app_id,      :string
    setting :facebook_api_secret,  :string

    # Customization
    setting :custom_header,        :string
    setting :custom_footer,        :string
    setting :custom_javascript,    :string

    def get(key)
      raise InvalidConfigurationKey, ":#{key} is not a valid configuration option" unless has_setting?(key)
      if configuration.has_key?(key)
        configuration[key]
      else
        self.class.settings[key].default
      end
    end

    def set(key, value)
      key = key.to_sym if key.kind_of?(String)
      unless has_setting?(key)
        raise InvalidConfigurationKey, ":#{key} is not a valid configuration option"
      end
      value = parse_value(key, value)
      unless valid_type?(key, value)
        raise ArgumentError, "expected #{self.class.settings[key].type}, got #{value.class}"
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

    def update(attributes={})
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
        value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
      else
        value.kind_of?(type_for(key).to_s.camelize.constantize)
      end
    end

    def parse_value(key, value)
      if type_for(key) == :boolean
        value = true  if value == :enabled
        value = false if value == :disabled
      end
      value
    end
  end
end
