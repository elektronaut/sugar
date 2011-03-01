class ScriptBundle

	class << self
		def bundle(name, &block)
			name = name.to_s
			@@bundles ||= {}
			@@bundles[name] ||= self.new
			yield @@bundles[name] if block_given?
			@@bundles[name]
		end
		
	end
	
	def initialize
		@scripts = []
	end
	
	def compressor
		@compressor ||= YUI::JavaScriptCompressor.new(:munge => true)
	end
	
	def add(script, options={})
		options = {:compress => false}.merge(options)
		@scripts << [script, options]
	end
	
	def scripts
		@scripts.map{|s| s.first}
	end

	def to_s
		output = []
		@scripts.each do |filename, options|
			script = File.read(Rails.root.join("public/javascripts/#{filename}"))
			script = compressor.compress(script) if options[:compress]
			output << script
		end
		output.join("\n")
	end
	
	def write(filename)
		File.open(filename, 'w') do |fh|
			fh.write self.to_s
		end
	end
end