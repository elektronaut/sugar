# encoding: utf-8

# = ConversationRelationship

# Models the relationship between conversations and users.

class ConversationRelationship < ActiveRecord::Base
	belongs_to :user
	belongs_to :conversation
	validates_uniqueness_of :user_id, :scope => :conversation_id
end
