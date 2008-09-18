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
        User.refresh_xbox!(true)
    end

end