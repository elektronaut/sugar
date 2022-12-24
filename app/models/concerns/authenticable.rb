# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  # Virtual attributes for clear text passwords
  attr_accessor :password, :confirm_password

  included do
    before_validation :ensure_password, on: :create
    before_validation :encrypt_new_password
    before_validation :go_on_hiatus
    before_validation :clear_banned_until

    attribute :hiatus_until, :datetime

    enum status: { active: 0, inactive: 1, hiatus: 2, time_out: 3, banned: 4,
                   memorialized: 5 }

    validate do |user|
      if user.new_password? && !user.new_password_confirmed?
        user.errors.add(:password, :confirmation)
      end
    end

    validates :hashed_password,
              presence: true

    validates :facebook_uid,
              uniqueness: { case_sensitive: false },
              if: :facebook_uid?

    validate :verify_banned_until

    before_save :update_persistence_token
  end

  module ClassMethods
    def generate_token
      SecureRandom.hex(20)
    end

    def encrypt_password(password)
      BCrypt::Password.create(password)
    end

    def find_and_authenticate_with_password(email, password)
      return nil if email.blank?
      return nil if password.blank?

      user = User.find_by("LOWER(email) = ?", email.downcase.strip)
      return unless user&.valid_password?(password)

      user.hash_password!(password) if user.password_needs_rehash?
      user
    end
  end

  def deactivated?
    !active?
  end

  def facebook?
    facebook_uid?
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
    update(hashed_password: User.encrypt_password(password))
  end

  def new_password?
    password&.present? ? true : false
  end

  def new_password_confirmed?
    new_password? && password == confirm_password
  end

  def password_needs_rehash?
    hashed_password.length <= 40
  end

  def temporary_banned?
    banned_until? && banned_until > Time.now.utc
  end

  def check_status!
    return unless hiatus? || time_out?
    return if banned_until && banned_until > Time.now.utc

    update(status: :active)
  end

  protected

  def ensure_password
    return if new_password? || hashed_password?
    return unless facebook?

    self.password = self.confirm_password = SecureRandom.base64(15)
  end

  def encrypt_new_password
    return unless new_password? && new_password_confirmed?

    self.hashed_password = User.encrypt_password(password)
  end

  def clear_banned_until
    self.banned_until = nil if banned_until? && banned_until <= Time.now.utc
  end

  def go_on_hiatus
    return unless hiatus_until && hiatus_until > Time.now.utc

    self.status = :hiatus
    self.banned_until = hiatus_until
  end

  def verify_banned_until
    return unless hiatus? || time_out?
    return if banned_until?

    errors.add(:banned_until, "is required")
  end

  def update_persistence_token
    return unless !persistence_token || hashed_password_changed?

    self.persistence_token = self.class.generate_token
  end
end
