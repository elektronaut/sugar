# encoding: utf-8

module UserScopes
  extend ActiveSupport::Concern

  included do
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
  end

end