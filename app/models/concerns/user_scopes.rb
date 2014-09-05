# encoding: utf-8

module UserScopes
  extend ActiveSupport::Concern

  module ClassMethods
    def active
      where(banned: false)
    end

    def admins
      active.where("admin = ? OR user_admin = ? OR moderator = ?", true, true, true)
    end

    def banned
      where("banned = ? OR banned_until > ?", true, Time.now)
    end

    def by_username
      order("username ASC")
    end

    def online
      active.where("last_active > ?", 15.minutes.ago)
    end

    def social
      active.where("(twitter IS NOT NULL AND twitter != '') OR (instagram IS NOT NULL AND instagram != '') OR (flickr IS NOT NULL AND flickr != '')")
    end

    def recently_joined
      active.order("created_at DESC")
    end

    def top_posters
      active.where("public_posts_count > 0").order("public_posts_count DESC")
    end

    def trusted
      active.where("trusted = ? OR admin = ? OR user_admin = ? OR moderator = ?", true, true, true, true)
    end

    def xbox_users
      active.where("gamertag IS NOT NULL AND gamertag != ''")
    end

    def sony_users
      active.where("sony IS NOT NULL AND sony != ''")
    end
  end

end