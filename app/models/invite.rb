# encoding: utf-8

require 'digest/sha1'

class Invite < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :email, :user_id

  attr_accessor :used

  DEFAULT_EXPIRATION = 14.days

  validate :validate_email_registered

  before_create :set_token
  before_create :set_expires_at
  after_create :revoke_invite
  before_destroy :grant_invite

  scope :active, -> { where("expires_at >= ?", Time.now).include(:user) }
  scope :expired, -> { where("expires_at < ?", Time.now) }

  class << self
    # Makes a unique random token.
    def unique_token
      token = nil
      token = Digest::SHA1.hexdigest(rand(65535).to_s + Time.now.to_s) until token && !self.exists?(:token => token)
      token
    end

    def find_by_token(token)
      self.where(:token => token).first
    end

    # Gets the default expiration time.
    def expiration_time
      DEFAULT_EXPIRATION
    end

    # Deletes expired invites
    def destroy_expired!
      self.expired.each do |invite|
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

  private

  def revoke_invite
    self.user.revoke_invite!
  end

  def grant_invite
    self.user.grant_invite! unless self.used
  end

  def set_token
    self.token ||= Invite.unique_token
  end

  def set_expires_at
    self.expires_at ||= Time.now + Invite.expiration_time
  end

  def validate_email_registered
    if User.exists?(:email => self.email)
      self.errors.add(:email, 'is already registered!')
    end
    if Invite.active.select{|i| i != self && i.email == self.email }.length > 0
      self.errors.add(:email, 'has already been invited!')
    end
  end
end
