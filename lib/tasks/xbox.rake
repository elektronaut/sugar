namespace :xbox do
	desc "Testing something.."
	task :debug => :environment do
		xbox_users = XboxInfo.eligible_users
		gamertags = xbox_users.map{|u| u.gamertag}.uniq.sort

		# Load XML data
		concurrency = 15
		xml_docs = {}
		threads = []
		gamertags.in_groups(concurrency) do |grouped_gamertags|
			t = Thread.new do
				grouped_gamertags.each do |gamertag|
					if gamertag
						print "."
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
							puts "An error occured loading #{gamertag}: " + e
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
				user.xbox_info ||= XboxInfo.create(:user_id => user.id)
				user.xbox_info.update_from_xml(xml_doc)
				valid_xbox_users << user
			end
		end
		
		# Prune outdated records
		XboxInfo.find(:all, :include => [:user]).each do |xi|
			xi.destroy unless valid_xbox_users.include?(xi.user)
		end
	end
end