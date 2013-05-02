# encoding: utf-8

# = Conversation
#
# A conversation is a private Exchange only accessible to a subset of users.

class Conversation < Exchange

  include Sugar::Exceptions

  has_many :conversation_relationships, -> { order 'created_at ASC' }, dependent: :destroy
  has_many :participants, :through => :conversation_relationships, :source => :user

  after_create do |conversation|
    conversation.add_participant(conversation.poster, new_posts: false)
  end

  # Adds a participant
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

  # Removes a participant
  def remove_participant(user)
    if user.kind_of?(User) && self.participants.include?(user)
      raise RemoveParticipantError unless self.removeable?(user)
      ConversationRelationship.where(
        :user_id         => user.id,
        :conversation_id => self.id
      ).destroy_all
    end
  end

  # Can this participant be removed?
  def removeable?(user)
    user && self.participants.include?(user) && self.participants.count > 1
  end

  # Returns true if the user can view this conversation
  def viewable_by?(user)
    user && self.participants.include?(user)
  end

  # Returns true if the user can edit this conversation
  def editable_by?(user)
    user && user == self.poster
  end

  # Returns true if the user can post in this conversation
  def postable_by?(user)
    user && self.participants.include?(user)
  end

  # Returns true if the user can close this conversation
  def closeable_by?(user)
    false
  end

end
