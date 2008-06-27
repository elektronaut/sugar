namespace :b3s do

    desc "Setup test account"
    task :setup => :environment do
        admin = User.create(
            :username => 'elektronaut', 
            :realname => 'Inge Jørgensen', 
            :password => 'elektronaut', 
            :confirm_password => 'elektronaut', 
            :email => 'inge@elektronaut.no',
            :activated => true
        )
    end

end