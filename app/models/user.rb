require 'digest/sha1'
require 'md5'

class User < ActiveRecord::Base

    UNSAFE_ATTRIBUTES = :id, :username, :hashed_password, :admin, :activated, :banned, :trusted, :user_admin, :moderator, :last_active, :created_at, :updated_at, :posts_count, :discussions_count, :inviter_id

    # Virtual attributes for clear text passwords
	attr_accessor :password, :confirm_password
	attr_accessor :password_changed

	has_many   :discussions, :foreign_key => 'poster_id'
    has_many   :posts
    belongs_to :inviter, :class_name => 'User'
    has_many   :invitees, :class_name => 'User', :foreign_key => 'inviter_id'
    has_many   :discussion_views, :dependent => :destroy
    has_many   :discussion_relationships, :dependent => :destroy
    has_many   :messages, :foreign_key => 'recipient_id', :conditions => ['deleted = 0'], :order => ['created_at DESC']
    has_many   :unread_messages, :class_name => 'Message', :foreign_key => 'recipient_id', :conditions => ['deleted = 0 AND `read` = 0'], :order => ['created_at DESC']
    has_many   :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id', :conditions => ['deleted_by_sender = 0'], :order => ['created_at DESC']
    has_one    :xbox_info, :dependent => :destroy

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
				user.errors.add( :password,         "must be confirmed" )
			end
		end
	end
	
	validates_presence_of   :hashed_password, :username, :email
	validates_uniqueness_of :username
	validates_format_of     :username, :with => /^[\w\d\-\s_#!]+$/

    # Class methods
	class << self
	    
	    # Find active users
	    def find_active
	        self.find(:all, :conditions => 'activated = 1 AND banned = 0', :order => 'username ASC')
        end
	    
        # Finds users with activity within some_time. The last_active column is only 
        # updated every 10 minutes, smaller values won't work.
	    def find_online(some_time=15.minutes)
	        User.find(:all, :conditions => ['activated = 1 AND last_active > ?', some_time.ago], :order => 'username ASC')
        end
	    
		# Hash a string for password usage
		def hash_string( string )
			Digest::SHA1.hexdigest( string )
		end
		
        # Deletes attributes which normal users shouldn't be able to touch from a param hash
		def safe_attributes(params)
		    safe_params = params.dup
		    UNSAFE_ATTRIBUTES.each do |r|
		        safe_params.delete(r)
	        end
            return safe_params
	    end
	    
	    def find_new(since=14.days.ago)
	        self.find(:all, :conditions => ['activated = 1 AND banned = 0 AND created_at > ?', since], :order => 'username ASC')
        end
        
        def refresh_xbox!(force=false)
            self.find(:all, :conditions => ['activated = 1']).select{|u| u.gamertag?}.each do |u|
                u.refresh_xbox! if force || !u.xbox_refreshed?
            end
        end
	end
	
	def participated_discussions(options={})
		DiscussionRelationship.find_participated(self, options)
	end
	def following_discussions(options={})
		DiscussionRelationship.find_following(self, options)
	end
	def favorite_discussions(options={})
		DiscussionRelationship.find_favorite(self, options)
	end

    # Number of participated discussions
	def participated_count
		DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND participated = 1', self.id])
	end

    # Find and paginate discussions
    def paginated_discussions(options)
        num_discussions = options[:trusted] ? self.discussions.count(:all) : self.discussions.count(:all, :conditions => ['trusted = 0'])

        # Math is awesome
        limit = options[:limit] || Discussion::DISCUSSIONS_PER_PAGE
        num_pages = (num_discussions.to_f/limit).ceil
        page  = (options[:page] || 1).to_i
        page = 1 if page < 1
        page = num_pages if page > num_pages
        offset = limit * (page - 1)

        # Grab the discussions
        discussions = Discussion.find(
            :all, 
            :conditions => ['poster_id = ?', self.id], 
            :limit      => limit, 
            :offset     => offset, 
            :order      => 'sticky DESC, last_post_at DESC',
            :include    => [:poster, :last_poster, :category]
        )

        # Inject the pagination methods on the collection
        class << discussions; include Paginates; end
        discussions.setup_pagination(:total_count => discussions_count, :page => page, :per_page => limit)
        
        return discussions
    end

    # Find and paginate messages
    def paginated_messages(options={})
        num_messages = self.messages.count

        limit = options[:limit] || Message::MESSAGES_PER_PAGE
        num_pages = (num_messages.to_f/limit).ceil
        page  = (options[:page] || 1).to_i
        page = 1 if page < 1
        page = num_pages if page > num_pages
        offset = limit * (page - 1)
        
        messages = Message.find(
            :all,
            :conditions => ['recipient_id = ? AND deleted = 0', self.id],
            :order      => ['created_at DESC'],
            :limit      => limit, 
            :offset     => offset,
            :include    => [:sender]
        )

        # Inject the pagination methods on the collection
        class << messages; include Paginates; end
        messages.setup_pagination(:total_count => num_messages, :page => page, :per_page => limit)
        
        return messages
    end

    # Find and paginate sent messages
    def paginated_sent_messages(options={})
        num_messages = self.sent_messages.count

        limit = options[:limit] || Message::MESSAGES_PER_PAGE
        num_pages = (num_messages.to_f/limit).ceil
        page  = (options[:page] || 1).to_i
        page = 1 if page < 1
        page = num_pages if page > num_pages
        offset = limit * (page - 1)
        
        messages = Message.find(
            :all,
            :conditions => ['sender_id = ? AND deleted_by_sender = 0', self.id],
            :order      => ['created_at DESC'],
            :limit      => limit, 
            :offset     => offset,
            :include    => [:recipient]
        )

        # Inject the pagination methods on the collection
        class << messages; include Paginates; end
        messages.setup_pagination(:total_count => num_messages, :page => page, :per_page => limit)
        
        return messages
    end

	# Find conversation partners
	def conversation_partners
		User.find_by_sql("SELECT u.* FROM users u, messages m WHERE (m.sender_id = #{self.id} AND m.recipient_id = u.id) OR (m.recipient_id = #{self.id} AND m.sender_id = u.id) ORDER BY m.created_at DESC").uniq
	end
	
	# Find last message with user
	def last_message_with(user)
		Message.find(:first, :conditions => ['(sender_id = ? AND recipient_id = ?) OR (recipient_id = ? AND sender_id = ?)', self.id, user.id, self.id, user.id], :order => 'created_at DESC')
	end
	
	# Number of messages exchanged with user
	def message_count_with(user)
		Message.count(:all, :conditions => ['(sender_id = ? AND recipient_id = ?) OR (recipient_id = ? AND sender_id = ?)', self.id, user.id, self.id, user.id])
	end
	
	# Number of unread messages from user
	def unread_message_count_from(user)
		Message.count(:all, :conditions => ['sender_id = ? AND recipient_id = ? AND `read` = 0', user.id, self.id])
	end
	
	# Do we have unread message from user?
	def unread_messages_from?(user)
		(unread_message_count_from(user) > 0) ? true : false
	end

    # Find and paginate sent messages
    def paginated_conversation(options={})
        user = options[:user]
        conditions = ['(sender_id = ? AND recipient_id = ? AND deleted_by_sender = 0) OR (recipient_id = ? AND sender_id = ? AND deleted = 0)', self.id, user.id, self.id, user.id]
        num_messages = Message.count(:all, :conditions => conditions)

        limit = options[:limit] || Message::MESSAGES_PER_PAGE
        num_pages = (num_messages.to_f/limit).ceil
        if options[:page] && options[:page].to_s == "last"
            page = num_pages
        else
            page  = (options[:page] || 1).to_i
            page = 1 if page < 1
            page = num_pages if page > num_pages
        end
        offset = limit * (page - 1)
        offset = 0 if offset < 0
        
        messages = Message.find(
            :all,
            :conditions => conditions,
            :order      => ['created_at ASC'],
            :limit      => limit, 
            :offset     => offset,
            :include    => [:recipient,:sender]
        )

        # Inject the pagination methods on the collection
        class << messages; include Paginates; end
        messages.setup_pagination(:total_count => num_messages, :page => page, :per_page => limit)
        
        return messages
    end

    def generate_password!
        new_password = ''
        seed = [0..9,'a'..'z','A'..'Z'].map(&:to_a).flatten.map(&:to_s)
        (5+rand(3)).times{ new_password += seed[rand(seed.length)] }
        self.password = self.confirm_password = new_password
    end
	
    def unread_messages_count
        @unread_messages_count ||= self.unread_messages.count
    end
    
    def unread_messages?
        (unread_messages_count > 0) ? true : false
    end

    def full_email
        self.realname? ? "#{self.realname} <#{self.email}>" : self.email
    end

    # Is the password valid?
	def valid_password?(pass)
		(self.class.hash_string(pass) == self.hashed_password) ? true : false
	end
	
    # Is the user online?
	def online?
	    (self.last_active && self.last_active > 15.minutes.ago) ? true : false
    end
    
    def trusted?
        (self[:trusted] || admin?)
    end
    
    def user_admin?
        (self[:user_admin] || admin?)
    end

	def following?(discussion)
		relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
		(relationship && relationship.following?) ? true : false
	end

	def favorite?(discussion)
		relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
		(relationship && relationship.favorite?) ? true : false
	end

    # Generates a Gravatar URL
    def gravatar_url(options={})
        options[:size] ||= 24
        @gravatar_url ||= {}
        unless @gravatar_url[options[:size]]
            gravatar_hash = MD5::md5(self.email)
            @gravatar_url[options[:size]] = "http://www.gravatar.com/avatar/#{gravatar_hash}?s=#{options[:size]}&amp;r=any"
        end
        @gravatar_url[options[:size]]
    end
    
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
