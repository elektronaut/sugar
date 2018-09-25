# frozen_string_literal: true

class ExchangeSerializer < ApplicationSerializer
  set_type :exchange
  attributes :id, :title, :nsfw, :closed, :sticky, :trusted, :created_at,
             :last_post_at, :posts_count

  attribute :new_posts_count do |exchange, params|
    params[:tracker].new_posts(exchange)
  end

  attribute :last_viewed_page do |exchange, params|
    params[:tracker].last_page(exchange)
  end

  has_one :poster, record_type: :user, serializer: UserSerializer
  has_one :last_poster, record_type: :user, serializer: UserSerializer

  belongs_to :last_viewed_post, record_type: :post do |exchange, params|
    params[:tracker].last_post(exchange)
  end

  link :posts_url do |exchange|
    helper.polymorphic_path([exchange, :posts], format: :json)
  end
end
