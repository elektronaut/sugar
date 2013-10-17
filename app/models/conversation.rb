# encoding: utf-8

# = Conversation
#
# A conversation is a private Exchange only accessible to a subset of users.

class Conversation < Exchange
  class RemoveParticipantError < StandardError; end

  has_many :conversation_relationships, -> { order 'created_at ASC' }, dependent: :destroy
  has_many :participants, through: :conversation_relationships, source: :user

  after_create do |conversation|
    conversation.add_participant(conversation.poster, new_posts: false)
  end

  def add_participant(user, options={})
    options = {
      new_posts: true
    }.merge(options)
    if user.kind_of?(User) && !self.participants.include?(user)
      ConversationRelationship.create(
        user:         user,
        conversation: self,
        new_posts:    options[:new_posts]
      )
    end
  end

  def remove_participant(user)
    if user.kind_of?(User) && self.participants.include?(user)
      raise RemoveParticipantError unless self.removeable?(user)
      ConversationRelationship.where(
        user_id:         user.id,
        conversation_id: self.id
      ).destroy_all
    end
  end

  def removeable?(user)
    user && self.participants.include?(user) && self.participants.count > 1
  end

  def viewable_by?(user)
    user && self.participants.include?(user)
  end

  def editable_by?(user)
    user && user == self.poster
  end

  def postable_by?(user)
    user && self.participants.include?(user)
  end

  def closeable_by?(user)
    false
  end

end
