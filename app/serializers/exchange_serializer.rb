# frozen_string_literal: true

class ExchangeSerializer
  include FastJsonapi::ObjectSerializer
  set_type :exchange
  attributes :id, :title, :nsfw, :closed, :sticky, :trusted, :created_at,
             :last_post_at, :posts_count

  has_one :poster, record_type: :user, serializer: UserSerializer
  has_one :last_poster, record_type: :user, serializer: UserSerializer
  has_many :posts, record_type: :post
end
