require "digest/sha1"

class User < ActiveRecord::Base

	attr_accessor :password, :confirm_password
	attr_accessor :password_changed

    has_many :discussions do
        def participated
            # Return participated discussions
        end
    end
    has_many :posts
    belongs_to :inviter, :class_name => 'User'
    has_many :invitees, :class_name => 'User'

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

	class << self
	    
	    def find_online(some_time=15.minutes)
	        User.find(:all, :conditions => ['activated = 1 AND last_active > ?', some_time.ago], :order => 'username ASC')
        end
	    
		# Hash a string for password usage
		def hash_string( string )
			Digest::SHA1.hexdigest( string )
		end
	end
	
	def valid_password?( pass )
		(self.class.hash_string(pass) == self.hashed_password) ? true : false
	end
	
	def online?
	    (self.last_active > 15.minutes.ago) ? true : false
    end
	
end
