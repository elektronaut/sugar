module Authenticable
  extend ActiveSupport::Concern

  # Virtual attributes for clear text passwords
  attr_accessor :password, :confirm_password

  included do
    # Automatically generate a password for Facebook and OpenID users
    before_validation(:on => :create) do |user|
      if (user.openid_url? || user.facebook?) && !user.hashed_password? && (!user.password || user.password.blank?)
        user.generate_password!
      end
    end

    validate do |user|
      # Has the password been changed?
      if user.password && !user.password.blank?
        if user.password == user.confirm_password
          user.hashed_password = User.encrypt_password(user.password)
        else
          user.errors.add(:password, "must be confirmed")
        end
      end
      # Normalize OpenID URL
      if user.openid_url && !user.openid_url.blank?
        user.openid_url = "http://"+user.openid_url unless user.openid_url =~ /^https?:\/\//
        user.openid_url = OpenID.normalize_url(user.openid_url)
      end
    end

    validates_presence_of   :hashed_password, :unless => Proc.new{|u| u.openid_url? || u.facebook?}
    validates_uniqueness_of :openid_url, :allow_nil => true, :allow_blank => true, :message => 'is already registered.', :case_sensitive => false
    validates_uniqueness_of :facebook_uid, :allow_nil => true, :allow_blank => true, :message => 'is already registered.'

    before_save do |user|
      user.banned_until = nil if user.banned_until? && user.banned_until <= Time.now
    end
  end

  module ClassMethods
    # Creates an encrypted password
    def encrypt_password(password)
      BCrypt::Password.create(password)
    end
  end

  # Generates a new password for this user.
  def generate_password!
    new_password = ''
    seed = [0..9,'a'..'z','A'..'Z'].map(&:to_a).flatten.map(&:to_s)
    (7+rand(3)).times{ new_password += seed[rand(seed.length)] }
    self.password = self.confirm_password = new_password
  end

  # Is the password valid?
  def valid_password?(pass)
    if self.hashed_password.length <= 40
      # Legacy SHA1
      Digest::SHA1.hexdigest(pass) == self.hashed_password
    else
      BCrypt::Password.new(self.hashed_password) == pass
    end
  end

  # Update the password hash
  def hash_password!(password)
    self.update_attribute(:hashed_password, User.encrypt_password(password))
  end

  # Does the password need rehashing?
  def password_needs_rehash?
    self.hashed_password.length <= 40
  end

  # Returns true if this user is temporarily banned.
  def temporary_banned?
    self.banned_until? && self.banned_until > Time.now
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

end