require 'hpricot'
require 'uv'

module PostParser
    def PostParser.parse(string)
		string = string.strip

		# Autolink URLs
		string.gsub!(/(^|\s)((ftp|https?):\/\/[^\s]+)\b/){ "#{$1}<a href=\"#{$2}\">#{$2}</a>" }
        
        # Youtube videos
        # <video type="youtube">td6m3OhO5zE</video>
        #string.gsub(/<video type="youtube">[\w\d]+<\/video>/){}

		doc = Hpricot(string)
		doc.search('code') do |codeblock|
			codeblock.swap( Uv.parse(codeblock.inner_html, "xhtml", 'javascript', true, 'twilight') )
		end
		string = doc.to_html

        # Replace line breaks
		string.gsub!(/\r?\n/,'<br />')

        return string
    end
end