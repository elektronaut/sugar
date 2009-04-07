namespace :b3s do

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

	desc "Pack default theme"
	task :pack_default_theme do
		`zip -r public/b3s_default_theme.zip public/stylesheets/default/* public/images/themes/default/*`
	end
	
	desc "Pack"
	task :pack => [:pack_default_theme] do
		puts "Packing javascript files..."
		`juicer merge --force public/javascripts/application.js`
		js_files = ['jquery', 'swfobject', 'application.min'].map{|f| "public/javascripts/#{f}.js"}.join(" ")
		`cat #{js_files} > public/javascripts/all.js`
	end

	desc "Disable web"
	task :disable_web do
		require 'erb'
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
		#User.refresh_xbox!(true)
		XboxInfo.refresh!(true)
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

end