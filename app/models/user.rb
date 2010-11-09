require 'digest/sha1'
require 'digest/md5'

# = User accounts
#
# === Users activation and banning
# Users must have the <tt>activated</tt> flag to be able to log in. They will 
# automatically be activated unless manual approval is enabled in the
# configuration. Non-active and banned users won't show up in the users lists.
#
# === Trusted users
# Users with the <tt>trusted</tt> flag can see the trusted categories and 
# discussions. Admin users also count as trusted.

class User < ActiveRecord::Base

	# The attributes in UNSAFE_ATTRIBUTES are blocked from <tt>update_attributes</tt> for regular users.
	UNSAFE_ATTRIBUTES = :id, :username, :hashed_password, :admin, :activated, :banned, :trusted, :user_admin, :moderator, :last_active, :created_at, :updated_at, :posts_count, :discussions_count, :inviter_id, :available_invites
	STATUS_OPTIONS    = :inactive, :activated, :banned

	# Virtual attributes for clear text passwords
	attr_accessor :password, :confirm_password
	attr_accessor :password_changed

	has_many   :discussions, :foreign_key => 'poster_id'
	has_many   :closed_discussions, :foreign_key => 'closer_id'
	has_many   :posts
	has_many   :discussion_posts, :class_name => 'Post', :conditions => {:conversation => false}
	belongs_to :inviter, :class_name => 'User'
	has_many   :invitees, :class_name => 'User', :foreign_key => 'inviter_id', :order => 'username ASC'
	has_many   :invites, :dependent => :destroy, :order => 'created_at DESC' do
		def active
			self.select{|i| !i.expired?}
		end
	end
	has_many   :discussion_views, :dependent => :destroy
	has_many   :discussion_relationships, :dependent => :destroy
	
	has_many   :conversation_relationships, :dependent => :destroy
	has_many   :conversations, :through => :conversation_relationships
	
	has_one    :xbox_info, :dependent => :destroy

	# Automatically generate a password for Facebook and OpenID users
	before_validation(:on => :create) do |user|
		if (user.openid_url? || user.facebook_uid?) && !user.hashed_password? && (!user.password || user.password.blank?)
			user.generate_password!
		end
	end
	
	validate do |user|
		# Has the password been changed?
		if user.password && !user.password.blank?
			if user.password == user.confirm_password
				new_hashed_password = User.hash_string( user.password )
				# Has the password changed?
				if new_hashed_password != user.hashed_password
					user.hashed_password = new_hashed_password
					user.password_changed = true
				end
			else
				user.errors.add(:password, "must be confirmed")
			end
		end
		# Normalize OpenID URL
		if user.openid_url && !user.openid_url.blank?
			user.openid_url = "http://"+user.openid_url unless user.openid_url =~ /^https?:\/\//
			user.openid_url = OpenID.normalize_url(user.openid_url)
		end
		# Set trusted to true if applicable
		user.trusted = true if user.moderator? && user.user_admin?
	end

	validates_presence_of   :hashed_password, :unless => Proc.new{|u| u.openid_url? || u.facebook_uid?}
	validates_uniqueness_of :openid_url, :allow_nil => true, :allow_blank => true, :message => 'is already registered.', :case_sensitive => false
	validates_uniqueness_of :facebook_uid, :allow_nil => true, :allow_blank => true, :message => 'is already registered.'

	validates_presence_of   :username
	validates_uniqueness_of :username, :message => 'is already registered.', :case_sensitive => false
	validates_format_of     :username, :with => /^[\w\d\-\s_#!]+$/

	validates_presence_of   :email, :unless => Proc.new{|u| u.openid_url? || u.facebook_uid?}, :case_sensitive => false
	validates_uniqueness_of :email, :message => 'is already registered.', :case_sensitive => false, :allow_nil => true, :allow_blank => true

	validates_presence_of   :realname, :application, :if => Proc.new{|u| Sugar.config(:signup_approval_required)}
	
	before_save do |user|
		user.banned_until = nil if user.banned_until? && user.banned_until <= Time.now
	end
	
	class << self
		# Finds active users.
		def find_active
			self.find(:all, :conditions => 'activated = 1 AND banned = 0', :order => 'username ASC')
		end

		# Finds users with activity within some_time. The last_active column is only 
		# updated every 10 minutes, smaller values won't work.
		def find_online(some_time=15.minutes)
			User.find(:all, :conditions => ['activated = 1 AND last_active > ?', some_time.ago], :order => 'username ASC')
		end

		# Finds admins.
		def find_admins
			User.find(:all, :order => 'username ASC', :conditions => 'activated = 1 AND banned = 0 AND (admin = 1 OR user_admin = 1 OR moderator = 1)')
		end

		# Finds Twitter users.
		def find_twitter_users
			User.find(:all, :order => 'username ASC', :conditions => 'activated = 1 AND banned = 0 AND twitter IS NOT NULL AND twitter != ""')
		end

		# Finds new users. Pass <tt>:limit</tt> as an option to control number 
		# of users fetched, this defaults to 25.
		def find_new(options={})
			options[:limit] ||= 25
			self.find(:all, :conditions => ['activated = 1 AND banned = 0'], :order => 'created_at DESC', :limit => options[:limit])
		end

		# Finds top posters. Pass <tt>:limit</tt> as an option to control number 
		# of users fetched, this defaults to 50.
		def find_top_posters(options={})
			options[:limit] ||= 50
			@users  = User.find(:all, :order => 'posts_count DESC', :conditions => 'activated = 1 AND banned = 0', :limit => options[:limit])
		end

		# Find trusted users
		def find_trusted
			User.find(:all, :order => 'username ASC', :conditions => 'activated = 1 AND banned = 0 AND (trusted = 1 OR admin = 1 OR user_admin = 1 OR moderator = 1)')
		end

		# Hash a string for password usage.
		def hash_string( string )
			Digest::SHA1.hexdigest( string )
		end
		
		# Deletes attributes which normal users shouldn't be able to touch from a param hash.
		def safe_attributes(params)
			safe_params = params.dup
			UNSAFE_ATTRIBUTES.each do |r|
				safe_params.delete(r)
			end
			return safe_params
		end

		# Refreshes Xbox Live info for all users.
		def refresh_xbox!(force=false)
			self.find(:all, :conditions => ['activated = 1']).select{|u| u.gamertag?}.each do |u|
				u.refresh_xbox! if force || !u.xbox_refreshed?
			end
		end
	end

	# Finds participated discussions. 
	# See <tt>DiscussionView.find_participated</tt> for options.
	def participated_discussions(options={})
		DiscussionRelationship.find_participated(self, options)
	end

	# Finds followed discussions.
	# See <tt>DiscussionView.find_following</tt> for options.
	def following_discussions(options={})
		DiscussionRelationship.find_following(self, options)
	end

	# Finds favorite discussions.
	# See <tt>DiscussionView.find_favorite</tt> for options.
	def favorite_discussions(options={})
		DiscussionRelationship.find_favorite(self, options)
	end

	# Finds and paginate discussions created by this user.
	# === Parameters
	# * <tt>:trusted</tt> - Boolean, includes discussions in trusted categories.
	# * <tt>:limit</tt>   - Number of discussions per page. Default: Discussion::DISCUSSIONS_PER_PAGE
	# * <tt>:page</tt>    - Page, defaults to 1.
	def paginated_discussions(options)
		Pagination.paginate(
			:total_count => options[:trusted] ? self.discussions.count(:all) : self.discussions.count(:all, :conditions => ['trusted = 0']),
			:per_page    => options[:limit] || Discussion::DISCUSSIONS_PER_PAGE,
			:page        => options[:page] || 1
		) do |pagination|
			discussions = Discussion.find(
				:all, 
				:conditions => options[:trusted] ? ['poster_id = ?', self.id] : ['poster_id = ? AND trusted = 0', self.id], 
				:limit      => pagination.limit, 
				:offset     => pagination.offset, 
				:order      => 'sticky DESC, last_post_at DESC',
				:include    => [:poster, :last_poster, :category]
			)
		end
	end
	
	def paginated_conversations(options)
		Pagination.paginate(
			:total_count => ConversationRelationship.count(:all, :conditions => {:user_id => self.id}),
			:per_page    => options[:limit] || Discussion::DISCUSSIONS_PER_PAGE,
			:page        => options[:page] || 1
		) do |pagination|
			joins = "INNER JOIN `conversation_relationships` ON `conversation_relationships`.conversation_id = `discussions`.id"
			joins += " AND `conversation_relationships`.user_id = #{self.id}"
			conversations = Conversation.find(
				:all,
				:select     => '`discussions`.*',
				:joins      => joins,
				:limit      => pagination.limit, 
				:offset     => pagination.offset, 
				:order      => '`discussions`.last_post_at DESC',
				:include    => [:poster, :last_poster]
			)
		end
	end

	# Finds and paginate posts created by this user.
	# === Parameters
	# * <tt>:trusted</tt> - Boolean, includes posts in trusted categories.
	# * <tt>:limit</tt>   - Number of posts per page. Default: Post::POSTS_PER_PAGE
	# * <tt>:page</tt>    - Page, defaults to 1.
	def paginated_posts(options)
		Pagination.paginate(
			:total_count => options[:trusted] ? self.discussion_posts.count(:all) : self.discussion_posts.count(:all, :conditions => {:conversation => false, :trusted => false}),
			:per_page    => options[:limit] || Post::POSTS_PER_PAGE,
			:page        => options[:page] || 1
		) do |pagination|
			Post.find(
				:all, 
				:conditions => options[:trusted] ? ['user_id = ? AND conversation = 0', self.id] : ['user_id = ? AND trusted = 0 AND conversation = 0', self.id], 
				:limit      => pagination.limit, 
				:offset     => pagination.offset, 
				:order      => 'created_at DESC',
				:include    => [:user, :discussion]
			)
		end
	end

	# Marks a discussion as viewed
	def mark_discussion_viewed(discussion, post, index)
		if discussion_view = DiscussionView.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
			discussion_view.update_attributes(:post_index => index, :post_id => post.id) if discussion_view.post_index < index
		else
			DiscussionView.create(:discussion_id => discussion.id, :user_id => self.id, :post_index => index, :post_id => post.id)
		end
	end

	# Calculates messages per day, rounded to a number of decimals determined by <tt>precision</tt>.
	def posts_per_day(precision=2)
		ppd = posts_count.to_f / ((Time.now - self.created_at).to_f / 60 / 60 / 24)
		number = ppd.to_s.split(".")[0]
		scale = ppd.to_s.split(".")[1][0..(precision-1)]
		"#{number}.#{scale}".to_f
	end

	# Generates a new password for this user.
	def generate_password!
		new_password = ''
		seed = [0..9,'a'..'z','A'..'Z'].map(&:to_a).flatten.map(&:to_s)
		(7+rand(3)).times{ new_password += seed[rand(seed.length)] }
		self.password = self.confirm_password = new_password
	end

	def unread_conversations_count
		@unread_conversations_count ||= self.conversation_relationships.count(:all, :conditions => {:new_posts => true, :notifications => true})
	end

	def unread_conversations?
		unread_conversations_count > 0
	end

	# Returns the full email address with real name.
	def full_email
		self.realname? ? "#{self.realname} <#{self.email}>" : self.email
	end
	
	# Returns realname or username
	def realname_or_username
		self.realname? ? self.realname : self.username
	end

	# Is the password valid?
	def valid_password?(pass)
		(self.class.hash_string(pass) == self.hashed_password) ? true : false
	end

	# Is the user online?
	def online?
		(self.last_active && self.last_active > 15.minutes.ago) ? true : false
	end

	# Returns true if this user is trusted or an admin.
	def trusted?
		(self[:trusted] || admin? || user_admin? || moderator?)
	end

	# Returns true if this user is a user admin.
	def user_admin?
		(self[:user_admin] || admin?)
	end

	# Returns true if this user is a moderator.
	def moderator?
		(self[:moderator] || admin?)
	end

	# Returns true if this user is following the given discussion.
	def following?(discussion)
		relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
		relationship && relationship.following?
	end

	# Returns true if this user has favorited the given discussion.
	def favorite?(discussion)
		relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
		relationship && relationship.favorite?
	end
	
	# Returns true if this user is temporarily banned.
	def temporary_banned?
		self.banned_until? && self.banned_until > Time.now
	end
	
	# Returns true if this user has invited someone.
	def invites?
		self.invites.count > 0
	end

	# Returns true if this user has invitees.
	def invitees?
		self.invitees.count > 0
	end
	
	# Returns true if this user has invited someone or has invitees.
	def invites_or_invitees?
		self.invites? || self.invitees?
	end

	# Returns true if this user can invite someone.
	def available_invites?
		self.user_admin? || self.available_invites > 0
	end
	
	# Number of remaining invites. User admins always have at least one invite.
	def available_invites
	 	number = self[:available_invites]
	 	self.user_admin? ? 1 : self[:available_invites]
	end

	# Revokes invites from a user, default = 1. Pass :all as an argument to revoke all invites.
	def revoke_invite!(number=1)
		return self.available_invites if self.user_admin?
		number = self.available_invites if number == :all
		new_invites = self.available_invites - number
		new_invites = 0 if new_invites < 0
		self.update_attribute(:available_invites, new_invites)
		self.available_invites
	end
	
	# Grants a number of invites to a user.
	def grant_invite!(number=1)
		return self.available_invites if self.user_admin?
		new_number = (self.available_invites + number)
		self.update_attribute(:available_invites, new_number)
		self.invites
	end

	# Get account status
	def status
		return 2 if banned?
		return 1 if activated?
		return 0
	end

	# Set account status
	def status=(new_status)
		new_status = STATUS_OPTIONS[new_status.to_i] unless new_status.kind_of?(Symbol)
		case new_status
		when :banned
			self.banned    = true
			self.activated = true
		when :activated
			self.banned    = false
			self.activated = true
		when :inactive
			self.banned    = false
			self.activated = false
		end
	end

	# Generates a Gravatar URL
	def gravatar_url(options={})
		options[:size] ||= 24
		@gravatar_url ||= {}
		unless @gravatar_url[options[:size]]
			gravatar_hash = Digest::MD5.hexdigest(self.email)
			@gravatar_url[options[:size]] = "http://www.gravatar.com/avatar/#{gravatar_hash}?s=#{options[:size]}&amp;r=any"
		end
		@gravatar_url[options[:size]]
	end
	
	# Returns admin flags as strings
	def admin_labels
		labels = []
		if self.admin?
			labels << "Admin"
		else
			labels << "User Admin" if self.user_admin?
			labels << "Moderator" if self.moderator?
		end
		labels
	end

	# Fixes any inconsistencies in the counter_cache columns.
	def fix_counter_cache!
		if posts_count != posts.count
			logger.warn "counter_cache error detected on User ##{self.id} (posts)"
			User.update_counters(self.id, :posts_count => (posts.count - posts_count) )
		end
		if discussions_count != discussions.count
			logger.warn "counter_cache error detected on User ##{self.id} (discussions)"
			User.update_counters(self.id, :discussions_count => (discussions.count - discussions_count) )
		end
	end
end
