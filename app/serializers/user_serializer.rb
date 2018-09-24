# frozen_string_literal: true

class UserSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  attributes :id, :username, :realname, :latitude, :longitude, :inviter_id,
             :last_active, :created_at, :description, :admin, :moderator,
             :user_admin, :location, :gamertag, :twitter, :flickr, :instagram,
             :website, :sony, :nintendo, :nintendo_switch, :steam, :battlenet,
             :msn, :gtalk, :last_fm, :facebook_uid, :banned_until, :status
end
