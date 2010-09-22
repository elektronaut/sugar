# = Conversation
#
# A conversation is a private Exchange only accessible to a subset of users.

class Conversation < Exchange
	has_many :conversation_relationships, :dependent => :destroy, :order => 'created_at ASC'
	has_many :participants, :through => :conversation_relationships, :source => :user
	
	after_create do |conversation|
		ConversationRelationship.create(:user => conversation.poster, :conversation => conversation)
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