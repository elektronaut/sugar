# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
    def formatted_time(time, options={})
        return "Never" unless time
        if time > 14.days.ago
            time_ago_in_words(time)+" ago"
        else
            time.strftime("%b %d, %Y")
        end
    end
    
    # Generates a link to the users profile
    def profile_link(user)
        link_to user.username, user_path(:id => user.username), :title => "#{user.username}'s profile"
    end
    
    def format_post(string)
        PostParser.parse(string)
    end
    
end
