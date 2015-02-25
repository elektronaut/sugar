class ViewedTracker
  def initialize(user)
    @user = user
  end

  def any?
    (user && exchanges.any?) ? true : false
  end

  def exchanges=(new_exchanges)
    clear_cache! unless new_exchanges == exchanges
    @exchanges = new_exchanges
  end

  def last_page(exchange)
    return 1 unless user
    if new_posts?(exchange)
      post_index = view(exchange).post_index
      if post_index == 0
        1
      else
        (post_index.to_f / Post.per_page).ceil
      end
    else
      exchange.last_page
    end
  end

  def last_post_id(exchange)
    return nil unless any?
    view(exchange).post_id
  end

  def last_post_id?(exchange)
    return false unless any?
    view(exchange).post_id?
  end

  def new_posts(exchange)
    return 0 unless any?
    exchange.posts_count - view(exchange).post_index
  end

  def new_posts?(exchange)
    new_posts(exchange) > 0
  end

  private

  def clear_cache!
    @views = nil
  end

  def exchanges
    @exchanges || []
  end

  def empty_view(exchange)
    ExchangeView.new(
      user_id:     user.id,
      exchange_id: exchange.id,
      post_index:  0
    )
  end

  def user
    @user
  end

  def views
    @views ||= ExchangeView.where(
      user_id:     user.id,
      exchange_id: exchanges.map(&:id).uniq
    ).to_a
  end

  def view(exchange)
    views.detect { |v| v.exchange_id == exchange.id } || empty_view(exchange)
  end
end
