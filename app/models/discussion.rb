class Discussion < Exchange
	has_many   :discussion_relationships, :dependent => :destroy

	belongs_to :category
	validates_presence_of :category_id
	
	# Flag for trusted status, which will update after save if it has been changed.
	attr_accessor :update_trusted

	validate do |discussion|
		discussion.trusted = discussion.category.trusted if discussion.category
	end

	before_update do |discussion|
		discussion.update_trusted = true if discussion.trusted_changed?
	end

	# Set trusted status on all posts and relationships on save
	after_save do |discussion|
		if discussion.update_trusted
			[Post, DiscussionRelationship].each do |c|
				c.update_all("trusted = " + (discussion.trusted? ? '1' : '0'), "discussion_id = #{discussion.id}")
			end
		end
	end
	
	class << self
		# Finds popular discussions within a defined time range, sorted by popularity.
		# The collection is decorated with the Pagination module, which provides pagination info.
		# Takes the following options: 
		# * :page     - Page number, starting on 1 (default: first page)
		# * :since    - Since time
		# * :limit    - Number of posts per page (default: 20)
		# * :trusted  - Boolean, get trusted posts as well
		def find_popular(options={})
			options = {
				:since => 7.days.ago
			}.merge(options)

			conditions = ['posts.discussion_id = discussions.id AND posts.created_at > ?', options[:since]]

			# Ignore trusted posts unless requested
			unless options[:trusted]
				conditions = [[conditions.shift, 'discussions.trusted = 0'].compact.join(' AND ')] + conditions
			end
			
			if options[:trusted]
				discussions_count = Discussion.count_by_sql(["SELECT COUNT(DISTINCT discussion_id) 
					FROM posts, discussions 
					WHERE posts.discussion_id = discussions.id AND posts.created_at > ? AND discussions.type = \"Discussion\"", options[:since]])
			else
				discussions_count = Discussion.count_by_sql(["SELECT COUNT(DISTINCT discussion_id) 
					FROM posts, discussions 
					WHERE posts.discussion_id = discussions.id AND posts.created_at > ? AND discussions.type = \"Discussion\" AND discussions.trusted = 0", options[:since]])
			end

			Pagination.paginate(
				:total_count => discussions_count,
				:per_page    => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE,
				:page        => options[:page]  || 1
			) do |pagination|
				discussions = Discussion.find(
					:all,
					:select     => 'discussions.*, COUNT(posts.id) AS recent_posts_count',
					:from       => 'discussions, posts',
					:conditions => conditions,
					:group      => 'discussions.id',
					:limit      => pagination.limit, 
					:offset     => pagination.offset, 
					:order      => 'recent_posts_count DESC'
				)
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
	
	# Returns true if the user can view this discussion
	def viewable_by?(user)
		if self.trusted?
			(user && user.trusted?) ? true : false
		else
			(Sugar.config(:public_browsing) || user) ? true : false
		end
	end

	# Returns true if the user can edit this discussion
	def editable_by?(user)
		(user && (user.moderator? || user == self.poster)) ? true : false
	end

	# Returns true if the user can post in this discussion
	def postable_by?(user)
		(user && (user.moderator? || !self.closed?)) ? true : false
	end

	# Returns true if the user can close this discussion
	def closeable_by?(user)
		return false unless user
		(user.moderator? || (!self.closer && self.poster == user) || self.closer == user) ? true : false
	end

end