# frozen_string_literal: true

require "digest/sha1"

class Invite < ApplicationRecord
  belongs_to :user
  validates :email, presence: true

  attr_accessor :used

  DEFAULT_EXPIRATION = 14.days

  validate :validate_email_registered

  before_create :set_token
  before_create :set_expires_at
  after_create :revoke_invite
  before_destroy :grant_invite

  scope :active, -> { where("expires_at >= ?", Time.now.utc).includes(:user) }
  scope :expired, -> { where("expires_at < ?", Time.now.utc) }

  class << self
    # Makes a unique random token.
    def unique_token
      token = nil
      token = SecureRandom.hex(20) until token && !exists?(token: token)
      token
    end

    def expiration_time
      DEFAULT_EXPIRATION
    end

    def destroy_expired!
      expired.each(&:destroy)
    end
  end

  def expired?
    Time.now.utc > expires_at
  end

  def expire!
    self.used = true
    destroy
  end

  private

  def revoke_invite
    user.revoke_invite!
  end

  def grant_invite
    user.grant_invite! unless used
  end

  def set_token
    self.token ||= Invite.unique_token
  end

  def set_expires_at
    self.expires_at ||= Time.now.utc + Invite.expiration_time
  end

  def validate_email_registered
    errors.add(:email, "is already registered!") if User.exists?(email: email)
    return unless Invite.active.any? do |i|
      i != self && i.email == email
    end

    errors.add(:email, "has already been invited!")
  end
end
