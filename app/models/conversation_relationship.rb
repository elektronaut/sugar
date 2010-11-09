class ConversationRelationship < ActiveRecord::Base
	belongs_to :user
	belongs_to :conversation
	validates_uniqueness_of :user_id, :scope => :conversation_id
end
