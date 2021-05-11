# frozen_string_literal: true

class ViewedTracker
  def initialize(user)
    @user = user
  end

  def any?
    user.present? && exchanges.any?
  end

  def exchanges=(new_exchanges)
    clear_cache! unless new_exchanges == exchanges
    @exchanges = new_exchanges
  end

  def last_page(exchange)
    return 1 unless user

    if new_posts?(exchange)
      index = view(exchange).post_index
      [(index.to_f / Post.per_page).ceil, 1].max
    else
      exchange.last_page
    end
  end

  def last_post(exchange)
    id = last_post_id(exchange)
    Post.find(id) if id
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
    new_posts(exchange).positive?
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
      user_id: user.id,
      exchange_id: exchange.id,
      post_index: 0
    )
  end

  attr_reader :user

  def views
    @views ||= ExchangeView.where(
      user_id: user.id,
      exchange_id: exchanges.map(&:id).uniq
    ).to_a
  end

  def view(exchange)
    views.detect { |v| v.exchange_id == exchange.id } || empty_view(exchange)
  end
end
