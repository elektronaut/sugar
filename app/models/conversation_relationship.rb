# frozen_string_literal: true

# = ConversationRelationship

# Models the relationship between conversations and users.

class ConversationRelationship < ApplicationRecord
  belongs_to :user
  belongs_to :conversation
  validates :user_id, uniqueness: { scope: :conversation_id }
end
