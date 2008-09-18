require 'rubygems'
require 'hpricot'
require 'open-uri'

class XboxLive

    API_URL = "http://duncanmackenzie.net/services/GetXboxInfo.aspx?GamerTag="

    attr_reader :xml_doc, :xml_data

    def initialize(gamertag, xml_data)
        @gamertag = gamertag
        @xml_data = xml_data
    end
    
    class << self
        def api_url(gamertag)
            API_URL + gamertag.gsub(' ','+')
        end
    end
    
    def xml_doc
        @xml_doc ||= Hpricot(@xml_data)
    end

    def valid?
        ((@valid ||= (xml_doc/"valid").first.inner_html rescue "false") == "true") ? true : false
    end

    def gamerscore
        @gamerscore ||= (xml_doc/"gamerscore").first.inner_html.to_i rescue nil
    end
    
    def last_seen
        @last_seen ||= Time.parse((xml_doc/"lastseen").first.inner_html) rescue nil
    end
    
    def status_text
        @status_text ||= (xml_doc/"statustext").first.inner_html rescue ""
    end
    
    def zone
        @zone ||= (xml_doc/"zone").first.inner_html rescue nil
    end

    def online?
        (status_text == 'Online' || status_text == 'Away') ? true : false
    end

    def away?
        (status_text == 'Away') ? true : false
    end

    def reputation
        @reputation ||= (xml_doc/"reputation").first.inner_html.to_f rescue nil
    end
    
    def info
        @info ||= (xml_doc/"info").first.inner_html rescue ""
    end

    def info2
        @info2 ||= (xml_doc/"info2").first.inner_html rescue ""
    end

    def tile_url
        @tile_url ||= (xml_doc/"tileurl").first.inner_html rescue nil
    end
    
    def method_missing(method_name, *params)
        m = method_name.to_s.gsub(/\?$/,'').to_sym
        if self.respond_to?(m)
            response = self.send(m)
            if response
                if response.kind_of?(String) && response.empty?
                    return false
                end
                return true
            end
            return false
        else
            super
        end
    end

end
