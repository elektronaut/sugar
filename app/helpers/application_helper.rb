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
    
    # Class names for discussion
    def discussion_classes(discussions, discussion)
        [discussion.labels.map(&:downcase), %w{odd even}[discussions.index(discussion)%2], (new_posts?(discussion) ? 'new_posts' : nil)].flatten.compact.join(' ')
    end
    
    def format_post(string)
        PostParser.parse(string)
    end
    
    def last_viewed_post(discussion)
        return discussion.posts_count unless @discussion_views
    end
    
    def discussion_view(discussion, user)
        return nil unless @discussion_views
        dv = @discussion_views.select{ |d| d.discussion_id == discussion.id && d.user_id == user.id }
        if dv.length == 0
            @discussion_views << (dv = DiscussionView.new(:user_id => user.id, :discussion_id => discussion.id, :post_index => 0))
            dv
        else
            dv.first
        end
    end
    
    def new_posts_count(discussion)
        return 0 unless @discussion_views
        discussion.posts_count - discussion_view(discussion, @current_user).post_index
    end

    def new_posts?(discussion)
        return false unless @discussion_views
        (new_posts_count(discussion) > 0) ? true : false
    end
    
    def last_discussion_page(discussion)
        return discussion.last_page unless @discussion_views && new_posts?(discussion)
        (discussion_view(discussion, @current_user).post_index.to_f / Post::POSTS_PER_PAGE).ceil + 1
    end
    
    def last_discussion_page_path(d)
        if @discussion_views && last_post_id = discussion_view(d, @current_user).post_id
            paged_discussion_path(:id => d, :page => last_discussion_page(d), :anchor => "post-#{last_post_id}")
        else
            paged_discussion_path(:id => d, :page => last_discussion_page(d))
        end
    end
    
end
