module ExchangeParticipant
  extend ActiveSupport::Concern

  included do
    has_many :discussions, foreign_key: 'poster_id'
    has_many :posts
    has_many :discussion_posts, class_name: 'Post', conditions: { conversation: false }
    has_many :discussion_views, dependent: :destroy
    has_many :discussion_relationships, dependent: :destroy

    has_many :participated_discussions,
             through: :discussion_relationships,
             source: :discussion,
             conditions: { discussion_relationships: { participated: true } }
    has_many :followed_discussions,
             through: :discussion_relationships,
             source: :discussion,
             conditions: { discussion_relationships: { following: true } }
    has_many :favorite_discussions,
             through: :discussion_relationships,
             source: :discussion,
             conditions: { discussion_relationships: { favorite: true } }

    has_many :conversation_relationships, dependent: :destroy
    has_many :conversations, through: :conversation_relationships
  end

  # Marks a discussion as viewed
  def mark_discussion_viewed(discussion, post, index)
    if discussion_view = DiscussionView.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
      discussion_view.update_attributes(:post_index => index, :post_id => post.id) if discussion_view.post_index < index
    else
      DiscussionView.create(:discussion_id => discussion.id, :user_id => self.id, :post_index => index, :post_id => post.id)
    end
  end

  def mark_conversation_viewed(conversation)
    self.conversation_relationships.where(conversation_id: conversation).first.update_attributes(new_posts: false)
  end

  # Calculates messages per day, rounded to a number of decimals determined by <tt>precision</tt>.
  def posts_per_day
    posts_count.to_f / ((Time.now - self.created_at).to_f / 1.day)
  end

  def unread_conversations_count
    self.conversation_relationships.count(
      :all,
      :conditions => {:new_posts => true, :notifications => true}
    )
  end

  def unread_conversations?
    unread_conversations_count > 0
  end

  # Finds relationship with discussion
  def discussion_relationship_with(discussion)
    self.discussion_relationships.where(:discussion_id => discussion.id).first
  end

  # Returns true if this user is following the given discussion.
  def following?(discussion)
    discussion_relationship_with(discussion) && discussion_relationship_with(discussion).following?
  end

  # Returns true if this user has favorited the given discussion.
  def favorite?(discussion)
    discussion_relationship_with(discussion) && discussion_relationship_with(discussion).favorite?
  end

end