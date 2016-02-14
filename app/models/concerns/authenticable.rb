module Authenticable
  extend ActiveSupport::Concern

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
              uniqueness: { message: "is already registered" },
              if: :openid_url?

    validates :facebook_uid,
              uniqueness: {
                message: "is already registered",
                case_sensitive: false
              },
              if: :facebook_uid?

    before_save :clear_banned_until
    before_save :update_persistence_token

    has_many :password_reset_tokens, dependent: :destroy
  end

  module ClassMethods
    def generate_token
      Digest::SHA1.hexdigest(rand(65535).to_s + Time.now.to_s)
    end

    def encrypt_password(password)
      BCrypt::Password.create(password)
    end

    def find_and_authenticate_with_password(username, password)
      return nil if username.blank?
      return nil if password.blank?
      user = User.find_by_username(username)
      if user && user.valid_password?(password)
        user.hash_password!(password) if user.password_needs_rehash?
        user
      end
    end
  end

  def facebook?
    self.facebook_uid?
  end

  def active
    !self.banned?
  end

  def valid_password?(pass)
    if hashed_password.length <= 40
      # Legacy SHA1
      Digest::SHA1.hexdigest(pass) == hashed_password
    else
      BCrypt::Password.new(hashed_password) == pass
    end
  end

  def hash_password!(password)
    update_attributes(hashed_password: User.encrypt_password(password))
  end

  def new_password?
    (password && !password.blank?) ? true : false
  end

  def new_password_confirmed?
    (self.new_password? && password == confirm_password) ? true : false
  end

  def password_needs_rehash?
    hashed_password.length <= 40
  end

  def temporary_banned?
    self.banned_until? && banned_until > Time.now
  end

  protected

  def ensure_password
    unless self.new_password? || self.hashed_password?
      if self.openid_url? || self.facebook?
        self.password = self.confirm_password = SecureRandom.base64(15)
      end
    end
  end

  def normalize_openid_url
    if self.openid_url?
      unless openid_url =~ /^https?:\/\//
        self.openid_url = "http://" + openid_url
      end
      self.openid_url = OpenID.normalize_url(openid_url)
    end
  end

  def encrypt_new_password
    if self.new_password? && self.new_password_confirmed?
      self.hashed_password = User.encrypt_password(password)
    end
  end

  def clear_banned_until
    if self.banned_until? && banned_until <= Time.now
      self.banned_until = nil
    end
  end

  def update_persistence_token
    if !persistence_token || self.hashed_password_changed?
      self.persistence_token = self.class.generate_token
    end
  end
end
