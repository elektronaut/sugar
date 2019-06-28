# frozen_string_literal: true

module UserScopes
  extend ActiveSupport::Concern

  module ClassMethods
    def active_and_memorialized
      where(status: %i[active memorialized])
    end

    def admins
      active_and_memorialized.where(
        "admin = ? OR user_admin = ? OR moderator = ?",
        true,
        true,
        true
      )
    end

    def temporarily_deactivated
      where(status: %i[hiatus time_out])
    end

    def deactivated
      where.not(status: %i[active memorialized])
    end

    def by_username
      order("username ASC")
    end

    def online
      active_and_memorialized.where("last_active > ?", 15.minutes.ago)
    end

    def social
      active_and_memorialized.where(
        "(twitter IS NOT NULL AND twitter != '') " \
        "OR (instagram IS NOT NULL AND instagram != '') " \
        "OR (flickr IS NOT NULL AND flickr != '')"
      )
    end

    def gaming
      active_and_memorialized.where(
        "(gamertag IS NOT NULL AND gamertag != '') " \
        "OR (sony IS NOT NULL AND sony != '') " \
        "OR (nintendo IS NOT NULL AND nintendo != '') " \
        "OR (nintendo_switch IS NOT NULL AND nintendo_switch != '') " \
        "OR (steam IS NOT NULL AND steam != '')" \
        "OR (battlenet IS NOT NULL AND battlenet != '')"
      )
    end

    def recently_joined
      active_and_memorialized.order("created_at DESC")
    end

    def top_posters
      active_and_memorialized.where("public_posts_count > 0")
                             .order("public_posts_count DESC")
    end
  end
end
