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

end