# encoding: utf-8

module ExchangesHelper

  # Returns an array of class names for an exchange
  def exchange_classes(collection, exchange)
    @exchange_classes ||= {}
    @exchange_classes[[collection, exchange]] ||= [
      exchange.labels.map(&:downcase),
      %w{odd even}[collection.to_a.index(exchange) % 2],
      (new_posts?(exchange) ? 'new_posts' : nil),
      "in_category#{exchange.category_id}",
      "by_user#{exchange.poster_id}",
      "discussion",
      "discussion#{exchange.id}"
    ]
  end

  def new_posts_count(discussion)
    return 0 unless @discussion_views
    discussion.posts_count - discussion_view(discussion, current_user).post_index
  end

  def new_posts?(discussion)
    return false unless @discussion_views
    @_new_posts ||= {}
    @_new_posts[discussion] ||= (new_posts_count(discussion) > 0) ? true : false
  end

  def last_viewed_page_path(exchange)
    last_page    = last_viewed_page(exchange)
    last_post_id = discussion_view(exchange, current_user).try(&:post_id)
    options = {}
    options[:page]   = last_page if last_page > 1
    options[:anchor] = "post-#{last_post_id}" if last_post_id

    polymorphic_path(exchange, options)
  end

  def post_page(post)
    if params[:controller] == 'discussions' && params[:action] == 'show' && @posts
      # Speed tweak
      @posts.current_page
    else
      post.page
    end
  end

  protected

  def discussion_view(discussion, user)
    return nil unless @discussion_views
    discussion_view_lookup_table[[discussion.id, user.id]] ||= DiscussionView.new(
      user_id:       user.id,
      discussion_id: discussion.id,
      post_index:    0
    )
  end

  def discussion_view_lookup_table
    @discussion_view_lookup_table ||= @discussion_views.inject(Hash.new) do |hash, dv|
      key = [dv.discussion_id, dv.user_id]
      unless hash[key] && hash[key].post_index > dv.post_index
        hash[key] = dv
      end
      hash
    end
  end

  def last_viewed_page(exchange)
    return 1 unless current_user?
    return exchange.last_page unless @discussion_views && new_posts?(exchange)
    page = (discussion_view(exchange, current_user)[:post_index].to_f / Post.per_page).ceil
    page = 1 if page < 1
    page
  end

end