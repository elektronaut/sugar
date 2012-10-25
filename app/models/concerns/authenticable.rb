module Authenticable
  extend ActiveSupport::Concern

  STATUS_OPTIONS = :inactive, :activated, :banned

  # Virtual attributes for clear text passwords
  attr_accessor :password, :confirm_password

  included do
    before_validation :ensure_password, on: :create
    before_validation :normalize_openid_url
    before_validation :encrypt_new_password

    validate do |user|
      if user.new_password? && !user.new_password_confirmed?
        user.errors.add(:password, "must be confirmed")
      end
    end

    validates :hashed_password,
              presence: true

    validates :openid_url,
              uniqueness: { message: 'is already registered' },
              if: :openid_url?

    validates :facebook_uid,
              uniqueness: { message: 'is already registered' },
              if: :facebook_uid?

    before_save :clear_banned_until
  end

  module ClassMethods
    # Creates an encrypted password
    def encrypt_password(password)
      BCrypt::Password.create(password)
    end
  end

  # Is this a Facebook user?
  def facebook?
    self.facebook_uid?
  end

  # Generates a new password for this user.
  def generate_new_password!
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
    self.update_attributes(hashed_password: User.encrypt_password(password))
  end

  # Has a new password been set?
  def new_password?
    self.password && !self.password.blank?
  end

  # Has the new password been confirmed?
  def new_password_confirmed?
    self.new_password? && self.password == self.confirm_password
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

  protected

    def ensure_password
      unless self.new_password? || self.hashed_password?
        if self.openid_url? || self.facebook?
          self.generate_new_password!
        end
      end
    end

    def normalize_openid_url
      if self.openid_url?
        unless self.openid_url =~ /^https?:\/\//
          self.openid_url = "http://" + self.openid_url
        end
        self.openid_url = OpenID.normalize_url(self.openid_url)
      end
    end

    def encrypt_new_password
      if self.new_password? && self.new_password_confirmed?
        self.hashed_password = User.encrypt_password(self.password)
      end
    end

    def clear_banned_until
      if self.banned_until? && self.banned_until <= Time.now
        self.banned_until = nil
      end
    end

end