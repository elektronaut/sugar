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

end