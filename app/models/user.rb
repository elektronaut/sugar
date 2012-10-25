# encoding: utf-8

require 'digest/sha1'

# = User accounts
#
# === Users activation and banning
# Users must have the <tt>activated</tt> flag to be able to log in. They will
# automatically be activated unless manual approval is enabled in the
# configuration. Non-active and banned users won't show up in the users lists.
#
# === Trusted users
# Users with the <tt>trusted</tt> flag can see the trusted categories and
# discussions. Admin users also count as trusted.

class User < ActiveRecord::Base
  include Authenticable, Inviter, ExchangeParticipant

  # The attributes in UNSAFE_ATTRIBUTES are blocked from <tt>update_attributes</tt>
  # for regular users.
  UNSAFE_ATTRIBUTES = :id, :username, :hashed_password, :admin, :activated, :banned,
                      :trusted, :user_admin, :moderator, :last_active, :created_at, :updated_at,
                      :posts_count, :discussions_count, :inviter_id, :available_invites

  before_validation :ensure_last_active_is_set

  validates :username,
            :presence => true,
            :uniqueness => { :case_sensitive => false, :message => "is already registered" },
            :format => { :with => /^[\p{Word}\d\-\s_#!]+$/, :message => "is not valid" }

  validates :email,
            :email => true,
            :uniqueness => { :case_sensitive => false, :message => 'is already registered' },
            :if => :email?

  validates :email,
            :presence => { :case_sensitive => false },
            :unless => Proc.new { |u| u.openid_url? || u.facebook? }

  validates :realname, :application,
            :presence => true,
            :if => Proc.new { |u| Sugar.config(:signup_approval_required) }

  scope :active,          where(:activated => true, :banned => false)
  scope :by_username,     order("username ASC")
  scope :banned,          lambda { where("banned = ? OR banned_until > ?", true, Time.now) }
  scope :online,          lambda { active.where("last_active > ?", 15.minutes.ago) }
  scope :admins,          active.where("admin = ? OR user_admin = ? OR moderator = ?", true, true, true)
  scope :xbox_users,      active.where("gamertag IS NOT NULL OR gamertag != ''")
  scope :social,          active.where("(twitter IS NOT NULL AND twitter != '') OR (instagram IS NOT NULL AND instagram != '') OR (flickr IS NOT NULL AND flickr != '')")
  scope :recently_joined, active.order("created_at DESC")
  scope :top_posters,     active.where("posts_count > 0").order("posts_count DESC")
  scope :trusted,         active.where("trusted = ? OR admin = ? OR user_admin = ? OR moderator = ?", true, true, true, true)

  class << self
    # Deletes attributes which normal users shouldn't be able to touch from a param hash.
    def safe_attributes(params)
      safe_params = params.dup
      UNSAFE_ATTRIBUTES.each do |r|
        safe_params.delete(r)
      end
      return safe_params
    end
  end

  # Returns the full email address with real name.
  def full_email
    self.realname? ? "#{self.realname} <#{self.email}>" : self.email
  end

  # Returns realname or username
  def realname_or_username
    self.realname? ? self.realname : self.username
  end

  # Is the user online?
  def online?
    (self.last_active && self.last_active > 15.minutes.ago) ? true : false
  end

  # Returns true if this user is trusted or an admin.
  def trusted?
    (self[:trusted] || admin? || user_admin? || moderator?)
  end

  # Returns true if this user is a user admin.
  def user_admin?
    (self[:user_admin] || admin?)
  end

  # Returns true if this user is a moderator.
  def moderator?
    (self[:moderator] || admin?)
  end

  # Returns admin flags as strings
  def admin_labels
    labels = []
    if self.admin?
      labels << "Admin"
    else
      labels << "User Admin" if self.user_admin?
      labels << "Moderator" if self.moderator?
    end
    labels
  end

  # Returns the chosen theme or the default one
  def theme
    self.theme? ? self.attributes['theme'] : Sugar.config(:default_theme)
  end

  # Returns the chosen mobile theme or the default one
  def mobile_theme
    self.mobile_theme? ? self.attributes['mobile_theme'] : Sugar.config(:default_mobile_theme)
  end

  # Avatar URL for Xbox Live
  def gamertag_avatar_url
    if self.gamertag?
      "http://avatar.xboxlive.com/avatar/#{URI.escape(self.gamertag)}/avatarpic-l.png"
    end
  end

  def as_json(options={})
    super({
      :only => [
        :id, :username, :realname, :latitude, :longitude, :inviter_id,
        :last_active, :created_at, :description, :admin,
        :moderator, :user_admin, :posts_count, :discussions_count,
        :location, :gamertag, :avatar_url, :twitter, :flickr, :instagram, :website,
        :msn, :gtalk, :last_fm, :facebok_uid, :banned_until
      ]
    }.merge(options))
  end

  def to_xml(options={})
    super({
      :only => [
        :id, :username, :realname, :latitude, :longitude, :inviter_id,
        :last_active, :created_at, :description, :admin,
        :moderator, :user_admin, :posts_count, :discussions_count,
        :location, :gamertag, :avatar_url, :twitter, :flickr, :instagram, :website,
        :msn, :gtalk, :last_fm, :facebok_uid, :banned_until
      ]
    }.merge(options))
  end

  protected

    def ensure_last_active_is_set
      self.last_active ||= Time.now
    end

end
