module PostParser
    def PostParser.parse(string)
        string = string.strip

        # Autolink URLs
        string.gsub!(/(^|\s)(ftp|https?):\/\/[^\s]+\b/){ |link| "<a href=\"#{link}\">#{link}</a>" }
        
        # Replace line breaks
        string.gsub!(/\r?\n/,'<br />')

        return string
    end
end