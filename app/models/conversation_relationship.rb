# encoding: utf-8

# = ConversationRelationship

# Models the relationship between conversations and users.

class ConversationRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation
  validates :user_id, uniqueness: { scope: :conversation_id }
end
