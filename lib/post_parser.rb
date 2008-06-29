module PostParser
    def PostParser.parse(string)
        string = string.strip

        # Autolink URLs
        string.gsub!(/(^|\s)((ftp|https?):\/\/[^\s]+)\b/){ "#{$1}<a href=\"#{$2}\">#{$2}</a>" }
        
        # Replace line breaks
        string.gsub!(/\r?\n/,'<br />')

        return string


    end
end