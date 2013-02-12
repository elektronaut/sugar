# encoding: utf-8

module ExchangesHelper

  # Class names for discussion
  def discussion_classes(discussions, discussion)
    @_discussion_classes ||= {}
    @_discussion_classes[[discussions, discussion]] ||= [
      discussion.labels.map(&:downcase),
      %w{odd even}[discussions.index(discussion)%2],
      (new_posts?(discussion) ? 'new_posts' : nil),
      "in_category#{discussion.category_id}",
      "by_user#{discussion.poster_id}",
      "discussion",
      "discussion#{discussion.id}"
    ].flatten.compact.join(' ')
  end

  # Class names for conversation
  def conversation_classes(users, user)
    [%w{odd even}[users.index(user)%2], (@current_user.unread_messages_from?(user) ? 'new_posts' : nil), "by_user#{user.id}", "conversation#{user.id}", "conversation"].flatten.compact.join(' ')
  end

  def last_viewed_post(discussion)
    return discussion.posts_count unless @discussion_views
  end

  def discussion_view(discussion, user)
    return nil unless @discussion_views
    @_discussion_view_lookup_table ||= @discussion_views.inject(Hash.new) do |hash, dv|
      hash[[dv.discussion_id, dv.user_id]] = dv unless hash[[dv.discussion_id, dv.user_id]] && hash[[dv.discussion_id, dv.user_id]].post_index > dv.post_index
      hash
    end
    @_discussion_view_lookup_table[[discussion.id, user.id]] ||= DiscussionView.new(:user_id => user.id, :discussion_id => discussion.id, :post_index => 0)
  end

  def new_posts_count(discussion)
    return 0 unless @discussion_views
    discussion.posts_count - discussion_view(discussion, @current_user).post_index
  end

  def new_posts?(discussion)
    return false unless @discussion_views
    @_new_posts ||= {}
    @_new_posts[discussion] ||= (new_posts_count(discussion) > 0) ? true : false
  end

  def last_discussion_page(discussion)
    return 1 unless @current_user
    return discussion.last_page unless @discussion_views && new_posts?(discussion)
    page = (discussion_view(discussion, @current_user)[:post_index].to_f / Post::POSTS_PER_PAGE).ceil
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

  def post_page(post)
    if params[:controller] == 'discussions' && params[:action] == 'show' && @posts
      # Speed tweak
      @posts.page
    else
      post.page
    end
  end

end