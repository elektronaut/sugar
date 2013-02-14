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
  include ActiveModel::ForbiddenAttributesProtection
  include Authenticable
  include Inviter
  include ExchangeParticipant
  include UserScopes

  before_create :check_for_first_user
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

  # Updates the last_active timestamp
  def mark_active!
    if !self.last_active || self.last_active < 10.minutes.ago
      self.update_column(:last_active, Time.now)
    end
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

  def serializable_params
    [
      :id, :username, :realname, :latitude, :longitude, :inviter_id,
      :last_active, :created_at, :description, :admin,
      :moderator, :user_admin, :posts_count, :discussions_count,
      :location, :gamertag, :avatar_url, :twitter, :flickr, :instagram, :website,
      :msn, :gtalk, :last_fm, :facebok_uid, :banned_until
    ]
  end

  def serializable_methods
    [:active, :banned]
  end

  def as_json(options={})
    super({:only => serializable_params, :methods => serializable_methods}.merge(options))
  end

  def to_xml(options={})
    super({:only => serializable_params, :methods => serializable_methods}.merge(options))
  end

  protected

    def ensure_last_active_is_set
      self.last_active ||= Time.now
    end

    def check_for_first_user
      unless User.any?
        self.admin = true
        self.activated = true
      end
    end

end
