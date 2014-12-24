module ExchangeParticipant
  extend ActiveSupport::Concern

  included do
    has_many :discussions, foreign_key: 'poster_id'
    has_many :posts
    has_many :discussion_posts, -> { where conversation: false }, class_name: 'Post'
    has_many :exchange_views, dependent: :destroy
    has_many :discussion_relationships, dependent: :destroy

    has_many :participated_discussions,
             -> { where discussion_relationships: { participated: true } },
             through: :discussion_relationships,
             source: :discussion
    has_many :followed_discussions,
             -> { where discussion_relationships: { following: true } },
             through: :discussion_relationships,
             source: :discussion
    has_many :favorite_discussions,
             -> { where discussion_relationships: { favorite: true } },
             through: :discussion_relationships,
             source: :discussion
    has_many :hidden_discussions,
             -> { where discussion_relationships: { hidden: true } },
             through: :discussion_relationships,
             source: :discussion

    has_many :conversation_relationships, dependent: :destroy
    has_many :conversations, through: :conversation_relationships
  end

  def unhidden_discussions
    Discussion.where(Discussion.arel_table[:id].in(self.hidden_discussions.map(&:id)).not)
  end

  def mark_exchange_viewed(exchange, post, index)
    if exchange_view = ExchangeView.where(user_id: self.id, exchange_id: exchange.id).first
      exchange_view.update_attributes(post_index: index, post_id: post.id) if exchange_view.post_index < index
    else
      ExchangeView.create(exchange_id: exchange.id, user_id: self.id, post_index: index, post_id: post.id)
    end
  end

  def mark_conversation_viewed(conversation)
    self.conversation_relationships.where(conversation_id: conversation).first.update_attributes(new_posts: false)
  end

  def posts_per_day
    public_posts_count.to_f / ((Time.now - self.created_at).to_f / 1.day)
  end

  def unread_conversations_count
    self.conversation_relationships.where(new_posts: true, notifications: true).count
  end

  def unread_conversations?
    unread_conversations_count > 0
  end

  def discussion_relationship_with(discussion)
    self.discussion_relationships.where(discussion_id: discussion.id).first
  end

  def following?(discussion)
    (discussion_relationship_with(discussion) &&
     discussion_relationship_with(discussion).following?) ? true : false
  end

  def favorite?(discussion)
    (discussion_relationship_with(discussion) &&
     discussion_relationship_with(discussion).favorite?) ? true : false
  end

  def hidden?(discussion)
    (discussion_relationship_with(discussion) &&
     discussion_relationship_with(discussion).hidden?) ? true : false
  end
end
