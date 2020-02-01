# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  set_type :user
  attributes :id, :username, :realname, :latitude, :longitude, :inviter_id,
             :last_active, :created_at, :description, :admin, :moderator,
             :user_admin, :location, :website, :facebook_uid, :banned_until,
             :status

  link :avatar_url do |user|
    if user.avatar
      helper.dynamic_image_path(user.avatar, size: "96x96", crop: true)
    end
  end
end
