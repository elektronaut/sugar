require 'open-uri'
require 'xbox_live'

class XboxInfo < ActiveRecord::Base
    belongs_to :user

	API_CONCURRENCY = 15

    class << self

        # Find users with gamertags set
        def eligible_users
            User.find(:all, :conditions => ['gamertag IS NOT NULL AND gamertag NOT LIKE ""'], :order => 'username ASC')
        end

        # Refresh all users. Pass true to force an update
        def refresh!
			xbox_users = XboxInfo.eligible_users
			gamertags = xbox_users.map{|u| u.gamertag}.uniq.sort

			# Load XML data
			xml_docs = {}
			threads = []
			gamertags.in_groups(API_CONCURRENCY) do |grouped_gamertags|
				t = Thread.new do
					grouped_gamertags.each do |gamertag|
						if gamertag
							begin
								api_url = XboxLive.api_url(gamertag)
								xml_doc = open(api_url).read
								valid_gamertag = (xml_doc =~ /<Valid>true<\/Valid>/) ? true : false
								if valid_gamertag
									xml_docs[gamertag] = xml_doc
								else
									xml_docs[gamertag] = :invalid
								end
							rescue Exception => e
								xml_docs[gamertag] = :error
							end
						end
					end
				end
				threads << t
			end
			threads.each{|t| t.join}

			# Update users
			valid_xbox_users = []
			xbox_users.each do |user|
				xml_doc = xml_docs[user.gamertag]
				if xml_doc == :invalid
					user.xbox_info.destroy if user.xbox_info
				elsif xml_doc == :error
					valid_xbox_users << user
				else
					user.xbox_info ||= self.create(:user_id => user.id)
					user.xbox_info.update_from_xml(xml_doc)
					valid_xbox_users << user
				end
			end

			# Prune outdated records
			self.find(:all, :include => [:user]).each do |xi|
				xi.destroy unless valid_xbox_users.include?(xi.user)
			end
        end
        
        # Find all valid users
        def valid_users
            User.find(:all, :include => [:xbox_info], :conditions => ['activated = 1 AND `xbox_infos`.valid_xml = 1']).sort do |a,b| 
                ((3 - a.xbox_info.status).to_s + a.username.downcase) <=> ((3 - b.xbox_info.status).to_s + b.username.downcase)
            end
        end
        
        # Last updated timestamp
        def last_updated
            self.find(:first, :conditions => ['valid_xml = 1'], :order => 'updated_at ASC').updated_at rescue nil
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

	def update_from_xml(xml_data)
		xml_parser = XboxLive.new(self.gamertag, xml_data)
		self.xml_data = xml_data
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

    # Refresh info from the API, pass true to force an update
    def refresh!(force=false)
        if force || !refreshed?
            logger.info "Refreshing Xbox Live info for #{gamertag}"
            self.xml_data = remote_xml
			self.update_from_xml(self.xml_data)
        end
    end
    
end
