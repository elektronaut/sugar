require 'pagination'

class Discussion < ActiveRecord::Base

	UNSAFE_ATTRIBUTES    = :id, :sticky, :user_id, :last_poster_id, :posts_count, :created_at, :last_post_at, :trusted
	DISCUSSIONS_PER_PAGE = 30

	belongs_to :poster,      :class_name => 'User', :counter_cache => true
	belongs_to :closer,      :class_name => 'User'
	belongs_to :last_poster, :class_name => 'User'
	belongs_to :category
	has_many   :posts, :order => ['created_at ASC'], :dependent => :destroy
	has_many   :discussion_views,                    :dependent => :destroy
	has_many   :discussion_relationships,            :dependent => :destroy

	validates_presence_of :category_id, :title
	validates_presence_of :body, :on => :create

	# Virtual attribute for the body of the first post. 
	# Makes forms a bit easier, no nested models.
	attr_accessor :body
	
	# Flag for trusted status, which will update after save if it has been changed.
	attr_accessor :update_trusted, :new_closer

	validate do |discussion|
		discussion.trusted = discussion.category.trusted if discussion.category
		if discussion.closed_changed?
			if !discussion.closed? && (!discussion.new_closer || !discussion.closeable_by?(discussion.new_closer))
				discussion.errors.add(:closed, "can't be changed!") 
			elsif discussion.closed?
				discussion.closer = discussion.new_closer
			else
				discussion.closer = nil
			end
		end
	end

	# Update the first post if @body has been changed
	after_update do |discussion|
		if discussion.body && !discussion.body.empty? && discussion.body != discussions.posts.first.body
			discussion.posts.first.update_attributes(:body => discussion.body, :edited_at => Time.now)
		end
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
	
	# Automatically create the first post
	after_create do |discussion|
		discussion.create_first_post!
	end

	define_index do
		indexes title
		has     poster_id, last_poster_id, category_id
		has     trusted
		has     closed
		has     sticky
		has     created_at, updated_at, last_post_at
		set_property :delta => :delayed
	end

	# Class methods
	class << self

		# Enable work safe URLs
		def work_safe_urls=(state)
			@@work_safe_urls = state
		end

		def work_safe_urls
			@@work_safe_urls ||= false
		end

		def search_paginated(options={})
			page  = (options[:page] || 1).to_i
			page = 1 if page < 1
			search_options = {
				:order     => :last_post_at, 
				:sort_mode => :desc, 
				:per_page  => DISCUSSIONS_PER_PAGE,
				:page      => page,
				:include   => [:poster, :last_poster, :category]
			}
			search_options[:conditions] = {:trusted => false} unless options[:trusted]
			discussions = Discussion.search(options[:query], search_options)
			Pagination.apply(discussions, Pagination::Paginater.new(:total_count => discussions.total_entries, :page => page, :per_page => DISCUSSIONS_PER_PAGE))
		end
		
		# Finds paginated discussions, sorted by activity, with the sticky ones on top.
		# The collection is extended with the Pagination module, which provides pagination info.
		# Takes the following options: 
		#     :page     - Page number, starting on 1 (default: first page)
		#     :limit    - Number of posts per page (default: 20)
		#     :category - Only get discussions in category
		def find_paginated(options={})
			if options[:trusted]
				discussions_count = (options[:category]) ? options[:category].discussions.count : Discussion.count
				conditions        = (options[:category]) ? ['category_id = ?', options[:category].id] : nil
			else
				discussions_count = (options[:category]) ? options[:category].discussions.count : Discussion.count(:conditions => 'trusted = 0')
				conditions        = (options[:category]) ? ['category_id = ? AND trusted = 0', options[:category].id] : 'trusted = 0'
			end

			Pagination.paginate(
				:total_count => discussions_count,
				:per_page    => options[:limit] || DISCUSSIONS_PER_PAGE,
				:page        => options[:page] || 1
			) do |pagination|
				Discussion.find(
					:all, 
					:conditions => conditions, 
					:limit      => pagination.limit, 
					:offset     => pagination.offset, 
					:order      => 'sticky DESC, last_post_at DESC',
					:include    => [:poster, :last_poster, :category]
				)
			end
		end

		# Deletes attributes which normal users shouldn't be able to touch from a param hash
		def safe_attributes(params)
			safe_params = params.dup
			UNSAFE_ATTRIBUTES.each do |r|
				safe_params.delete(r)
			end
			return safe_params
		end

	end
	
	# Finds paginated posts. See <tt>Post.find_paginated</tt> for more info.
	def paginated_posts(options={})
		Post.find_paginated({:discussion => self}.merge(options))
	end

	# Finds posts created since offset.
	def posts_since_index(offset)
		Post.find(:all, 
			:conditions => ['discussion_id = ?', self.id], 
			:order      => 'created_at ASC',
			:limit      => 200,
			:offset     => offset,
			:include    => [:user]
		)
	end

	# Finds the number of the last page.
	def last_page(per_page=Post::POSTS_PER_PAGE)
		(self.posts_count.to_f/per_page).ceil
	end

	# Creates the first post. This should probably be called from an after_create filter,
	# right now it's run manually from the controller.
	def create_first_post!
		if self.body && !self.body.empty?
			self.posts.create(:user => self.poster, :body => self.body)
		end
	end

	def fix_counter_cache!
		if posts_count != posts.count
			logger.warn "counter_cache error detected on Discussion ##{self.id}"
			Discussion.update_counters(self.id, :posts_count => (posts.count - posts_count) )
		end
	end

	# Does this discussion have any labels?
	def labels?
		(self.closed? || self.sticky? || self.nsfw? || self.trusted?) ? true : false
	end

	# Returns an array of labels (for use in the thread title)
	def labels
		labels = []
		labels << "Trusted" if self.trusted?
		labels << "Sticky" if self.sticky?
		labels << "Closed" if self.closed?
		labels << "NSFW" if self.nsfw?
		return labels
	end

	# Is this discussion editable by the given user?
	def editable_by?(user)
		(user && (user.admin? || user.moderator? || user == self.poster)) ? true : false
	end

	# Can the given user post in this thread?
	def postable_by?(user)
		(user && (user.admin? || user.moderator? || !self.closed?)) ? true : false
	end

	def viewable_by?(user)
		(user && !(self.trusted? && !(user.trusted? || user.admin?))) ? true : false
	end
	
	# Can the given user close this thread?
	def closeable_by?(user)
		return false unless user
		(user.moderator? || (!self.closer && self.poster == user) || self.closer == user) ? true : false
	end

	# Humanized ID for URLs
	def to_param
		slug = self.title
		slug = slug.gsub(/[\[\{]/,'(')
		slug = slug.gsub(/[\]\}]/,')')
		slug = slug.gsub(/[^\w\d!$&'()*,;=\-]+/,'-').gsub(/[\-]{2,}/,'-').gsub(/(^\-|\-$)/,'')
		(Discussion.work_safe_urls) ? self.id.to_s : "#{self.id.to_s};" + slug
	end
	
	if ENV['RAILS_ENV'] == 'test'
		def posts_count
			self.posts.count
		end 
	end
	
end
