# frozen_string_literal: true

class ExchangeResource
  include Alba::Resource

  attributes :id, :title, :nsfw, :closed, :sticky, :created_at,
             :last_post_at, :posts_count

  one :poster, resource: UserResource
  one :last_poster, resource: UserResource
end
