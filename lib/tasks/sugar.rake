namespace :sugar do

	desc "Generate new passwords for everyone and send welcome mail"
	task :welcome => :environment do 
		User.find_active.each do |user|
			user.generate_password!
			user.save
			begin
				Notifications.deliver_welcome(user)
			rescue
				puts "Couldn't send message to: #{user.username} - #{user.full_email}"
			end
		end
	end

	desc "Pack themes"
	task :pack_themes do
		themes_dir = File.join(File.dirname(__FILE__), '../../public/themes')
		Dir.entries(themes_dir).select{|d| File.exists?(File.join(themes_dir, d, 'screen.css'))}.each do |theme|
			`cd #{themes_dir} && zip -r #{theme}.zip #{theme}`
		end
	end
	
	desc "Pack javascripts"
	task :pack_scripts do
		puts "Minifying javascript files..."
		puts `juicer merge --force public/javascripts/application.js`
		js_files = ['jquery', 'swfobject', 'application.min'].map{|f| "public/javascripts/#{f}.js"}.join(" ")
		`cat #{js_files} > public/javascripts/all.js`

		puts "Minifying javascript files for the iPhone..."
		puts `juicer merge --force public/javascripts/iphone.js`
		js_files = ['jquery', 'iphone.min'].map{|f| "public/javascripts/#{f}.js"}.join(" ")
		`cat #{js_files} > public/javascripts/all.iphone.js`
		
		`rm public/javascripts/application.min.js`
		`rm public/javascripts/iphone.min.js`
		
		puts "All done!"
	end
	
	desc "Pack themes and javascripts"
	task :pack => [:pack_themes, :pack_scripts] do
	end

	desc "Disable web"
	task :disable_web do
		require 'erb'
		require File.join(File.dirname(__FILE__), 'sugar')
		reason = ENV['REASON'] || "DOWNTIME! The toobs are being vacuumed, check back in a couple of minutes."
		template_file = File.join(File.dirname(__FILE__), '../../config/maintenance.erb')
		template = ''; File.open(template_file){ |fh| template = fh.read }
		template = ERB.new(template)
		File.open(File.join(File.dirname(__FILE__), '../../public/system/maintenance.html'), "w") do |fh|
			fh.write template.result(binding)
		end
	end

	desc "Enable web"
	task :enable_web do
		maintenance_file = File.join(File.dirname(__FILE__), '../../public/system/maintenance.html')
		File.unlink(maintenance_file) if File.exist?(maintenance_file)
	end

	desc "Refresh Xbox Live"
	task :refresh_xbox => :environment do
		puts "Refreshing against Xbox API"
		start_time = Time.now
		XboxInfo.refresh!
		puts "Refresh finished in " + (Time.now - start_time).to_s + " seconds"
	end

	desc "Delete and reclaim expired invites"
	task :expire_invites => :environment do
		puts "Deleting expired invites"
		Invite.destroy_expired!
	end
	
	desc "Routine maintenance"
	task :routine => [:expire_invites] do
	end

	desc "Regenerate participated discussions"
	task :generate_participated_discussions => :environment do
		User.find(:all, :order => 'username ASC').each do |user|
			puts "Generating participated discussions for #{user.username}.."
			discussions = Discussion.find_by_sql("SELECT DISTINCT discussion_id AS id, trusted FROM posts WHERE user_id = #{user.id}")
			puts "  - #{discussions.length} discussions found, generating relationships"
			discussions.each do |d|
				DiscussionRelationship.define(user, d, :participated => true)
			end
		end
	end
	
	desc "Remove empty discussions"
	task :remove_empty_discussions => :environment do
		empty_discussions = Discussion.find(:all, :conditions => ['posts_count = 0'])
		puts "#{empty_discussions.length} empty discussions found, cleaning..."
		users      = empty_discussions.map{|d| d.poster}.compact.uniq
		categories = empty_discussions.map{|d| d.category}.compact.uniq
		empty_discussions.each do |d|
			d.destroy
		end
		users.each{|u| u.fix_counter_cache!}
		categories.each{|c| c.fix_counter_cache!}
	end
	
	desc "Converts Flickr usernames to user IDs"
	task :convert_flickr_usernames => :environment do
		require 'hpricot'
		require 'open-uri'
		users = User.find(:all, :conditions => ['flickr IS NOT NULL AND flickr != ""']).reject{|u| u.flickr =~ /[\w\d]+@[\w\d]+/}
		users.each do |u|
			puts "Converting #{u.flickr}..."
			url = "http://api.flickr.com/services/rest/?api_key=#{Sugar.config(:flickr_api)}&method=flickr.people.findByUsername&username=#{CGI.escape(u.flickr)}"
			doc = Hpricot.parse(open(url))
			user_id = (doc/'user').first.attributes['id'] rescue nil
			u.update_attribute(:flickr, user_id)
		end
	end

end