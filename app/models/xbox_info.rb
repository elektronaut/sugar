require 'open-uri'
require 'xbox_live'

class XboxInfo < ActiveRecord::Base
    belongs_to :user

    UPDATE_DELAY = 15.minutes
    
    class << self

        # Find users with gamertags set
        def eligible_users
            User.find(:all, :conditions => ['gamertag IS NOT NULL AND gamertag NOT LIKE ""'], :order => 'username ASC')
        end

        # Refresh all users. Pass true to force an update
        def refresh!(force=false)
            eligible_users.each do |user|
                user.xbox_info ||= self.new(:user_id => user.id)
                user.xbox_info.refresh!(force)
            end
        end
        
        # Find all valid users
        def valid_users
            User.find(:all, :include => [:xbox_info], :conditions => ['activated = 1 AND `xbox_infos`.valid_xml = 1']).sort do |a,b| 
                ((3 - a.xbox_info.status).to_s + a.username) <=> ((3 - b.xbox_info.status).to_s + b.username)
            end
        end
    end
    
    def gamertag
        self.user.gamertag
    end

    def api_url
        XboxLive.api_url(gamertag)
    end
    
    def remote_xml
        open(api_url).read
    end

    def refreshed?
        (!self.updated_at || (Time.now - UPDATE_DELAY) < self.updated_at) ? true : false
    end
    
    def xml_parser
        @xml_parser ||= XboxLive.new(gamertag, xml_data)
    end
    
    def online?;  (status && status == 2) ? true : false; end
    def away?;    (status && status == 1) ? true : false; end
    def offline?; (status && status == 0) ? true : false; end

    # Refresh info from the API, pass true to force an update
    def refresh!(force=false)
        if force || !refreshed?
            logger.info "Refreshing Xbox Live info for #{gamertag}"
            self.xml_data = remote_xml
            if xml_parser.valid?
                self.info        = xml_parser.info
                self.info2       = xml_parser.info2
                self.gamerscore  = xml_parser.gamerscore
                self.zone        = xml_parser.zone
                self.status_text = xml_parser.status_text
                self.reputation  = xml_parser.reputation
                self.tile_url    = xml_parser.tile_url
                self.valid_xml   = true
                if xml_parser.away?
                    self.status = 1
                elsif xml_parser.online?
                    self.status = 2
                else
                    self.status = 0
                end
            else
                self.valid_xml = false
            end
            self.save
        end
    end
    
end
