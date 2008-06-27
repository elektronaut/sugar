require 'digest/sha1'
require 'MD5'

class User < ActiveRecord::Base

    REJECT_PARAMS = :id, :username, :hashed_password, :admin, :activated, :banned, :last_active, :created_at, :updated_at, :posts_count, :discussions_count, :inviter_id

	attr_accessor :password, :confirm_password
	attr_accessor :password_changed

    has_many :discussions, :foreign_key => 'poster_id' do
        def participated
            # Return participated discussions
        end
    end
    has_many :posts
    belongs_to :inviter, :class_name => 'User'
    has_many :invitees, :class_name => 'User', :foreign_key => 'inviter_id'

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
	
	validates_presence_of :hashed_password, :username, :email
	validates_uniqueness_of :username
	validates_format_of :username, :with => /^[\w\d\-\s_#!]+$/

	class << self
	    
	    def find_online(some_time=15.minutes)
	        User.find(:all, :conditions => ['activated = 1 AND last_active > ?', some_time.ago], :order => 'username ASC')
        end
	    
		# Hash a string for password usage
		def hash_string( string )
			Digest::SHA1.hexdigest( string )
		end
		
		def safe_attributes(params)
		    safe_params = params.dup
		    REJECT_PARAMS.each do |r|
		        safe_params.delete(r)
	        end
            return safe_params
	    end
		
	end
	
	def valid_password?( pass )
		(self.class.hash_string(pass) == self.hashed_password) ? true : false
	end
	
	def online?
	    (self.last_active && self.last_active > 15.minutes.ago) ? true : false
    end
    
    def gravatar_url(options={})
        options[:size] ||= 24
        gravatar_hash = MD5::md5(self.email)
        "http://www.gravatar.com/avatar/#{gravatar_hash}?s=#{options[:size]}&amp;r=x"
    end
	
end
