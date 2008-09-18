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
    
    def meify(string, user)
        string.gsub(/(^|[\s])\/me/){ " " + link_to(user.username, user_path(user), :class => :poster) }
    end
    
    # Generates avatar image tag for a user
    def avatar_image_tag(user, size='32')
        if user.avatar_url?
            image_tag user.avatar_url, :alt => user.username, :size => "#{size}x#{size}"
	    else
            image_tag user.gravatar_url(:size => size), :alt => user.username, :size => "#{size}x#{size}"
		end
    end

    def add_body_class(*class_names)
        @body_classes ||= []
        @body_classes += [class_names].flatten # Should also work with arrays
    end
    
    def body_classes
        @body_classes ||= []
        @body_classes.uniq.join(' ')
    end
    
    def possessive(noun)
        (noun =~ /s$/) ? "#{noun}'" : "#{noun}'s"
    end
    
    # Generates a link to the users profile
    def profile_link(user, link_text=nil)
        link_text ||= user.username
        link_to link_text, user_path(:id => user.username), :title => "#{possessive(user.username)} profile"
    end
    
    # Class names for discussion
    def discussion_classes(discussions, discussion)
        [discussion.labels.map(&:downcase), %w{odd even}[discussions.index(discussion)%2], (new_posts?(discussion) ? 'new_posts' : nil), "in_category#{discussion.category_id}", "by_user#{discussion.poster_id}"].flatten.compact.join(' ')
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
        page = (discussion_view(discussion, @current_user).post_index.to_f / Post::POSTS_PER_PAGE).ceil
        page = 1 if page < 1
        page
    end
    
    def last_discussion_page_path(d)
        if ((last_page = last_discussion_page(d)) > 1)
            if @discussion_views && last_post_id = discussion_view(d, @current_user).post_id
                paged_discussion_path(:id => d.to_param, :page => last_page, :anchor => "post-#{last_post_id}")
            else
                paged_discussion_path(:id => d.to_param, :page => last_page)
            end
        else
            if @discussion_views && last_post_id = discussion_view(d, @current_user).post_id
                discussion_path(:id => d.to_param, :anchor => "post-#{last_post_id}")
            else
                discussion_path(:id => d.to_param)
            end
        end
    end
    
end
