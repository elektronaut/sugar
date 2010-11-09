require 'yaml'
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
		def load_config!
			unless defined?(@@config)
				@@config = DEFAULT_CONFIGURATION
				Setting.find(:all).each do |setting|
					key = setting.key.to_sym
					value = setting.value
					value = false if CONFIGURATION_BOOLEANS.include?(key) && value == '0'
					value = true if CONFIGURATION_BOOLEANS.include?(key) && value == '1'
					@@config[key] = value
				end
			end
		end
		
		def save_config!
			@@config.each do |key, value|
				Setting.set(key, value)
			end
		end

		def config(key=nil, value=nil)
			load_config!
			if key
				key = key.to_sym
				@@config[key] = value if value != nil
				@@config[key]
			else
				@@config
			end
		end
	
		def configure(options={})
			options.each do |key,value|
				self.config(key, value)
			end
		end
	
		def update_configuration(config)
			new_config = DEFAULT_CONFIGURATION
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
			@@config = new_config
			save_config!
		end
	end
end