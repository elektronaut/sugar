class Conversation < Exchange
	has_many :conversation_relationships, :dependent => :destroy, :order => 'created_at ASC'
	has_many :participants, :through => :conversation_relationships, :source => :user
	
	after_create do |conversation|
		ConversationRelationship.create(:user => conversation.poster, :conversation => conversation)
	end

	def viewable_by?(user)
		user && self.participants.include?(user)
	end
	
	# Is this discussion editable by the given user?
	def editable_by?(user)
		user && user == self.poster
	end

	# Can the given user post in this thread?
	def postable_by?(user)
		user && self.participants.include?(user)
	end

	# Can the given user close this thread?
	def closeable_by?(user)
		false
	end

end