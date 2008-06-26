# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
    def formatted_time(time, options={})
        if time > 14.days.ago
            time_ago_in_words(time)+" ago"
        else
            time.strftime("%b %d, %Y")
        end
    end
    
end
