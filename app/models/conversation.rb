# encoding: utf-8

# = Conversation
#
# A conversation is a private Exchange only accessible to a subset of users.

class Conversation < Exchange
  class RemoveParticipantError < StandardError; end

  has_many :conversation_relationships,
           -> { order "created_at ASC" },
           dependent: :destroy

  has_many :participants,
           -> { reorder("username ASC") },
           through: :conversation_relationships,
           source: :user

  after_create do |conversation|
    conversation.add_participant(conversation.poster, new_posts: false)
  end

  def add_participant(user, options = {})
    options = {
      new_posts: true
    }.merge(options)
    if user.is_a?(User) && !participants.include?(user)
      ConversationRelationship.create(
        user:         user,
        conversation: self,
        new_posts:    options[:new_posts]
      )
    end
  end

  def remove_participant(user)
    if user.is_a?(User) && participants.include?(user)
      raise RemoveParticipantError unless self.removeable?(user)
      ConversationRelationship.where(
        user_id:         user.id,
        conversation_id: id
      ).destroy_all
    end
  end

  def removeable?(user)
    user && participants.include?(user) && participants.count > 1
  end

  def removeable_by?(participant, remover)
    return false unless removeable?(participant)
    participant == remover ||
      remover.moderator? ||
      remover == poster
  end

  def viewable_by?(user)
    user && participants.include?(user)
  end

  def editable_by?(user)
    user && user == poster
  end

  def postable_by?(user)
    user && participants.include?(user)
  end

  def closeable_by?(_user)
    false
  end
end
