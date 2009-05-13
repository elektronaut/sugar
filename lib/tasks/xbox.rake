namespace :xbox do
	desc "Testing something.."
	task :debug => :environment do
		gamertags = XboxInfo.eligible_users.map{|u| u.gamertag}.uniq.sort
		puts "#{gamertags.length} unique gamertags found."
		start_time = Time.now

		xml_docs = {}
		
		concurrency = 15
		puts "Concurrency level: #{concurrency}"
		print "Loading "

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

		puts ""
		puts "Successfully loaded: " + xml_docs.select{|k,v| v != :invalid && v != :error}.length.to_s
		puts "Invalid: " + xml_docs.select{|k,v| v == :invalid}.length.to_s
		puts "Errors: " + xml_docs.select{|k,v| v == :error}.length.to_s

		puts "Requests finished in " + (Time.now - start_time).to_s + " seconds"
	end
end