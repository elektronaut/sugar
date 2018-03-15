module ExchangeParticipant
  extend ActiveSupport::Concern

  included do
    has_many :discussions, foreign_key: "poster_id"
    has_many :posts
    has_many :discussion_posts,
             -> { where conversation: false, deleted: false },
             class_name: "Post"
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
    Discussion.where(
      Discussion.arel_table[:id].in(hidden_discussions.map(&:id)).not
    )
  end

  def mark_exchange_viewed(exchange, post, index)
    view = ExchangeView.find_by(user_id: id, exchange_id: exchange.id)
    if view
      if view.post_index < index
        view.update(post_index: index, post_id: post.id)
      end
    else
      create_exchange_view(exchange, post, index)
    end
  end

  def mark_conversation_viewed(conversation)
    conversation_relationships
      .find_by(conversation_id: conversation)
      .update_attributes(new_posts: false)
  end

  def posts_per_day
    public_posts_count.to_f / ((Time.now.utc - created_at).to_f / 1.day)
  end

  def unread_conversations_count
    conversation_relationships.where(new_posts: true).count
  end

  def unread_conversations?
    unread_conversations_count > 0
  end

  def muted_conversation?(conversation)
    !conversation_relationships
      .where(notifications: true, conversation: conversation)
      .any?
  end

  def discussion_relationship_with(discussion)
    discussion_relationships.find_by(discussion_id: discussion.id)
  end

  def following?(discussion)
    if discussion_relationship_with(discussion) &&
       discussion_relationship_with(discussion).following?
      true
    else
      false
    end
  end

  def favorite?(discussion)
    if discussion_relationship_with(discussion) &&
       discussion_relationship_with(discussion).favorite?
      true
    else
      false
    end
  end

  def hidden?(discussion)
    if discussion_relationship_with(discussion) &&
       discussion_relationship_with(discussion).hidden?
      true
    else
      false
    end
  end

  private

  def create_exchange_view(exchange, post, index)
    ExchangeView.create(
      exchange_id: exchange.id,
      user_id: id,
      post_index: index,
      post_id: post.id
    )
  end
end
