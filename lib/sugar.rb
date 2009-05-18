require 'yaml'
module Sugar
	def self.config(key=nil, value=nil)
		@@config ||= YAML.load_file(File.join(File.dirname(__FILE__), '../config/sugar_conf.yml'))
		if key
			key = key.to_s
			@@config[key] = value if value != nil
			@@config[key]
		else
			@@config
		end
	end
	
	def self.configure(options={})
		options.each do |key,value|
			self.config(key, value)
		end
	end
end