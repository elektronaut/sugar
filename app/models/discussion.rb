class Discussion < Exchange
	has_many   :discussion_relationships, :dependent => :destroy

	belongs_to :category
	validates_presence_of :category_id
	
	validate do |discussion|
		discussion.trusted = discussion.category.trusted if discussion.category
	end

	# Set trusted status on all posts and relationships on save
	after_save do |discussion|
		if discussion.update_trusted
			[Post, DiscussionRelationship].each do |c|
				c.update_all("trusted = " + (discussion.trusted? ? '1' : '0'), "discussion_id = #{discussion.id}")
			end
		end
	end
	
	def participants
		User.find_by_sql("SELECT u.*, MAX(p.created_at) AS last_post_at
		FROM users u, posts p
		WHERE p.discussion_id = #{self.id} AND p.user_id = u.id
		GROUP BY u.id
		ORDER BY MAX(p.created_at) DESC")
	end
	
	def viewable_by?(user)
		if self.trusted?
			(user && user.trusted?) ? true : false
		else
			(Sugar.config(:public_browsing) || user) ? true : false
		end
	end

	# Is this discussion editable by the given user?
	def editable_by?(user)
		(user && (user.moderator? || user == self.poster)) ? true : false
	end

	# Can the given user post in this thread?
	def postable_by?(user)
		(user && (user.moderator? || !self.closed?)) ? true : false
	end

	# Can the given user close this thread?
	def closeable_by?(user)
		return false unless user
		(user.moderator? || (!self.closer && self.poster == user) || self.closer == user) ? true : false
	end

end