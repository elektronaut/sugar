class ConversationRelationship < ActiveRecord::Base
	belongs_to :user
	belongs_to :conversation
	belongs_to :message
end
