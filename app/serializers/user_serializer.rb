# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  set_type :user
  attributes :id, :username, :realname, :latitude, :longitude, :inviter_id,
             :last_active, :created_at, :description, :admin, :moderator,
             :user_admin, :location, :gamertag, :twitter, :flickr, :instagram,
             :website, :sony, :nintendo, :nintendo_switch, :steam, :battlenet,
             :msn, :gtalk, :last_fm, :facebook_uid, :banned_until, :status

  link :avatar_url do |user|
    helper.dynamic_image_path(user.avatar, size: "96x96", crop: true) if user.avatar
  end
end
