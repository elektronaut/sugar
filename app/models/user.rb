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

  # The attributes in UNSAFE_ATTRIBUTES are blocked from <tt>update_attributes</tt> for regular users.
  UNSAFE_ATTRIBUTES = :id, :username, :hashed_password, :admin, :activated, :banned, :trusted, :user_admin, :moderator, :last_active, :created_at, :updated_at, :posts_count, :discussions_count, :inviter_id, :available_invites
  STATUS_OPTIONS    = :inactive, :activated, :banned

  validate do |user|
    # Set trusted to true if applicable
    user.trusted = true if user.moderator? && user.user_admin?
  end

  validates_presence_of   :username
  validates_uniqueness_of :username, :message => 'is already registered.', :case_sensitive => false
  validates_format_of     :username, :with => /^[\p{Word}\d\-\s_#!]+$/

  validates_presence_of   :email, :unless => Proc.new{|u| u.openid_url? || u.facebook?}, :case_sensitive => false
  validates_uniqueness_of :email, :message => 'is already registered.', :case_sensitive => false, :allow_nil => true, :allow_blank => true

  validates_presence_of   :realname, :application, :if => Proc.new{|u| Sugar.config(:signup_approval_required)}

  class << self
    # Finds active users.
    def find_active
      self.find(:all, :conditions => ['activated = ? AND banned = ?', true, false], :order => 'username ASC')
    end

    # Finds users with activity within some_time. The last_active column is only
    # updated every 10 minutes, smaller values won't work.
    def find_online(some_time=15.minutes)
      User.find(:all, :conditions => ['activated = ? AND last_active > ?', true, some_time.ago], :order => 'username ASC')
    end

    # Finds admins.
    def find_admins
      User.find(:all, :order => 'username ASC', :conditions => ['activated = ? AND banned = ? AND (admin = ? OR user_admin = ? OR moderator = ?)', true, false, true, true, true])
    end

    # Finds Xbox Live users
    def find_xbox_users
      User.find(:all, :order => 'username ASC', :conditions => ['activated = ? AND banned = ? AND (gamertag IS NOT NULL AND gamertag != "")', true, false])
    end

    # Finds Twitter users.
    def find_social_users
      User.find(:all, :order => 'username ASC', :conditions => ['activated = ? AND banned = ? AND ((twitter IS NOT NULL AND twitter != "") OR (instagram IS NOT NULL AND instagram != "") OR (flickr IS NOT NULL AND flickr != ""))', true, false])
    end

    # Finds new users. Pass <tt>:limit</tt> as an option to control number
    # of users fetched, this defaults to 25.
    def find_new(options={})
      options[:limit] ||= 25
      self.find(:all, :conditions => ['activated = ? AND banned = ?', true, false], :order => 'created_at DESC', :limit => options[:limit])
    end

    # Finds top posters. Pass <tt>:limit</tt> as an option to control number
    # of users fetched, this defaults to 50.
    def find_top_posters(options={})
      options[:limit] ||= 50
      @users  = User.find(:all, :order => 'posts_count DESC', :conditions => ['activated = ? AND banned = ?', true, false], :limit => options[:limit])
    end

    # Find trusted users
    def find_trusted
      User.find(:all, :order => 'username ASC', :conditions => ['activated = ? AND banned = ? AND (trusted = ? OR admin = ? OR user_admin = ? OR moderator = ?)', true, false, true, true, true, true])
    end

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

  # Is this a Facebook user?
  def facebook?
    self.facebook_uid?
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

  # Returns true if this user is following the given discussion.
  def following?(discussion)
    relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
    relationship && relationship.following?
  end

  # Returns true if this user has favorited the given discussion.
  def favorite?(discussion)
    relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
    relationship && relationship.favorite?
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

  def as_json(options)
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

  def to_xml(options)
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
end
