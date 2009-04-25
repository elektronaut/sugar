module Sugar
	def self.config(key, value=nil)
		key = key.to_s
		@@config ||= {}
		@@config[key] = value if value != nil
		@@config[key]
	end
	
	def self.configure(options={})
		options.each do |key,value|
			self.config(key, value)
		end
	end
	
	config :flickr_api,          false
end