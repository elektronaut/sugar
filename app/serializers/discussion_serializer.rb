class DiscussionSerializer < ActiveModel::Serializer
  attributes :id, :title
  attributes :nsfw, :closed, :sticky, :trusted
  attributes :created_at, :last_post_at
  attributes :posts_count

  has_one :poster, embed: :id, include: true, root: 'users'
  has_one :last_poster, embed: :id, include: true, root: 'users'
end