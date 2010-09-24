require 'digest/sha1'

class Invite < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :email, :user_id
	
	attr_accessor :used

	DEFAULT_EXPIRATION = 14.days

	validate do |invite|
		invite.token ||= Invite.unique_token
		if User.exists?(:email => invite.email)
			invite.errors.add(:email, 'is already registered!')
		end
		if Invite.find_active.select{|i| i != invite && i.email == invite.email }.length > 0
			invite.errors.add(:email, 'has already been invited!')
		end
	end
	
	before_create do |invite|
		invite.expires_at ||= Time.now + Invite.expiration_time
		if invite.valid?
			invite.user.revoke_invite!
		end
	end
	
	before_destroy do |invite|
		invite.user.grant_invite! unless invite.used
	end
	
	class << self
		# Makes a unique random token.
		def unique_token
			token = nil
			token = Digest::SHA1.hexdigest(rand(65535).to_s + Time.now.to_s) until token && !self.exists?(:token => token)
			token
		end
		
		# Gets the default expiration time.
		def expiration_time
			DEFAULT_EXPIRATION
		end
		
		# Finds valid invites
		def find_active
			self.find(:all, :conditions => ['expires_at >= ?', Time.now], :order => 'created_at DESC', :include => [:user])
		end
		
		# Finds expired invites
		def find_expired
			self.find(:all, :conditions => ['expires_at < ?', Time.now], :order => 'created_at DESC')
		end
		
		# Deletes expired invites
		def destroy_expired!
			self.find_expired.each do |invite|
				invite.destroy
			end
		end
	end
	
	# Has this invite expired?
	def expired?
		(Time.now <= self.expires_at) ? false : true
	end
	
	# Expire this invite
	def expire!
		self.used = true
		self.destroy
	end
end
