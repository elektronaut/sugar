# encoding: utf-8

module UserScopes
  extend ActiveSupport::Concern

  module ClassMethods
    def active
      where(banned: false)
    end

    def admins
      active.where(
        "admin = ? OR user_admin = ? OR moderator = ?",
        true,
        true,
        true
      )
    end

    def banned
      where("banned = ? OR banned_until > ?", true, Time.now.utc)
    end

    def by_username
      order("username ASC")
    end

    def online
      active.where("last_active > ?", 15.minutes.ago)
    end

    def social
      active.where(
        "(twitter IS NOT NULL AND twitter != '') " \
        "OR (instagram IS NOT NULL AND instagram != '') " \
        "OR (flickr IS NOT NULL AND flickr != '')"
      )
    end

    def gaming
      active.where(
        "(gamertag IS NOT NULL AND gamertag != '') " \
        "OR (sony IS NOT NULL AND sony != '') " \
        "OR (nintendo IS NOT NULL AND nintendo != '') " \
        "OR (nintendo_switch IS NOT NULL AND nintendo_switch != '') " \
        "OR (steam IS NOT NULL AND steam != '')" \
        "OR (battlenet IS NOT NULL AND battlenet != '')"
      )
    end

    def recently_joined
      active.order("created_at DESC")
    end

    def top_posters
      active.where("public_posts_count > 0").order("public_posts_count DESC")
    end

    def trusted
      active.where(
        "trusted = ? OR admin = ? OR user_admin = ? OR moderator = ?",
        true,
        true,
        true,
        true
      )
    end
  end
end
