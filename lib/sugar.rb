# encoding: utf-8

require 'yaml'

require File.join(File.dirname(__FILE__), 'sugar/exceptions')

module Sugar

  DEFAULT_CONFIGURATION = {
    :forum_name               => 'Sugar',
    :forum_short_name         => 'Sugar',
    :forum_title              => 'Sugar',

    # Hosts etc
    :default_domain           => nil,
    :asset_host               => nil,
    :mail_sender              => nil,
    :session_key              => '_sugar_session',

    # Themes
    :default_theme            => 'default',
    :default_theme            => 'default',
    :default_mobile_theme     => 'default',

    # Options
    :public_browsing          => false,
    :signups_allowed          => true,
    :signup_approval_required => false,

    # Integration
    :xbox_live_enabled        => false,
    :flickr_api               => nil,
    :google_analytics         => nil,
    :amazon_associates_id     => nil,

    # Facebook integration
    :facebook_app_id          => nil,
    :facebook_api_key         => nil,
    :facebook_api_secret      => nil,

    # Customization
    :custom_header            => nil,
    :custom_footer            => nil,
    :custom_javascript        => nil,
  }
  CONFIGURATION_BOOLEANS = [:public_browsing, :signups_allowed, :signup_approval_required, :xbox_live_enabled]

  class << self
    attr_accessor :redis, :redis_prefix

    def redis
      @redis ||= Redis.new
    end

    def redis_prefix
      unless @redis_prefix
        raise "Sugar.redis_prefix has not been configured! Check that you've set up config/initializers/sugar.rb."
      end
      @redis_prefix
    end

    def load_config!
      @config = Hash[DEFAULT_CONFIGURATION]
      if saved_config = Sugar.redis.get("#{Sugar.redis_prefix}:configuration")
        @config = @config.merge(JSON.parse(saved_config).symbolize_keys)
      end
      @config
    end

    def save_config!
      Sugar.redis.set("#{Sugar.redis_prefix}:configuration", @config.to_json)
    end

    def reset_config!
      update_configuration(DEFAULT_CONFIGURATION)
    end

    def config(key=nil, value=nil)
      load_config! unless @config
      if key
        key = key.to_sym
        @config[key] = value if value != nil
        @config[key]
      else
        @config
      end
    end

    def configure(options={})
      options.each do |key,value|
        self.config(key, value)
      end
    end

    def public_browsing?
      self.config(:public_browsing)
    end

    def update_configuration(config)
      new_config = Hash[DEFAULT_CONFIGURATION]
      config_keys = config.keys.map{|k| k.to_sym}
      CONFIGURATION_BOOLEANS.each do |key|
        config[key] = false unless config_keys.include?(key)
      end
      config.each do |key, value|
        key = key.to_sym
        if CONFIGURATION_BOOLEANS.include?(key)
          new_config[key] = (!value || value == '0' || value.to_s == 'false') ? false : true
        else
          new_config[key] = value
        end
      end
      @config = new_config
      save_config!
    end
  end
end
