namespace :benchmark do
    
    desc "Create random users"
    task :create_users => :environment do
        count = User.count
        100.times do |i|
            User.create(:username => "random user #{count + i}", :password => "loser", :confirm_password => "loser", :email => "email@email.com", :activated => true, :last_active => Time.now)
        end
    end
    
    desc "Generate 500 random discussions"
    task :create_discussions => :environment do
        users = User.find(:all)
        categories = Category.find(:all)
        randlimit = rand(12000)
        lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        count = Discussion.count
        1.times do |i|
            u = users[rand(users.length - 1)]
            d = u.discussions.create(
                :title  => "Hugeass PS3 thread", 
                :category => categories[rand(categories.length - 1)],
                :nsfw => (rand > 0.7) ? true : false,
                :sticky => (rand > 0.999) ? true : false,
                :closed => (rand > 0.9) ? true : false,
                :body => lorem
            )
            #d.create_first_post!
            9000.times do |i|
               d.posts.create(:body => lorem, :user => users[rand(users.length - 1)]) 
            end
            puts "#{d.title}: #{d.posts.count} posts"
        end
    end
end