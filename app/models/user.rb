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
    has_many   :messages, :foreign_key => 'recipient_id', :conditions => ['deleted = 0'], :order => ['created_at DESC']
    has_many   :unread_messages, :class_name => 'Message', :foreign_key => 'recipient_id', :conditions => ['deleted = 0 AND read = 0'], :order => ['created_at DESC']
    has_many   :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id', :conditions => ['deleted_by_sender = 0'], :order => ['created_at DESC']

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
				user.errors.add( :confirm_password, "must be confirmed" )
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
	        self.find(:all, :conditions => 'activated = 1 AND banned = 0')
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
	end
	
    # Number of participated discussions
    def participated_count(options={})
        if options[:trusted]
            Post.count_by_sql("SELECT COUNT(DISTINCT discussion_id) FROM posts WHERE posts.user_id = #{self.id}")
        else
            Post.count_by_sql("SELECT COUNT(DISTINCT p.discussion_id) FROM posts p, discussions d WHERE p.user_id = #{self.id} AND p.discussion_id = d.id AND d.trusted = 0")
        end
    end

    # Find and paginate participated discussions
	def paginated_discussions(options)
	    num_discussions = self.participated_count(:trusted => options[:trusted])

        limit = options[:limit] || Discussion::DISCUSSIONS_PER_PAGE
        num_pages = (num_discussions.to_f/limit).ceil
        page  = (options[:page] || 1).to_i
        page = 1 if page < 1
        page = num_pages if page > num_pages
        offset = limit * (page - 1)
        
        if options[:trusted]
            conditions = ['posts.user_id = ?', self.id]
        else
            conditions = ['posts.user_id = ? AND discussions.trusted = 0', self.id]
        end

        discussions = Discussion.find(
            :all,
            :joins      => "INNER JOIN posts ON discussions.id = posts.discussion_id",
            :group      => "discussions.id",
            :conditions => conditions,
            :limit      => limit, 
            :offset     => offset,
            :order      => 'sticky DESC, last_post_at DESC',
            :include    => [:poster, :last_poster, :category]
        )

        # Inject the pagination methods on the collection
        class << discussions; include Paginates; end
        discussions.setup_pagination(:total_count => num_discussions, :page => page, :per_page => limit)
        
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
	
end
