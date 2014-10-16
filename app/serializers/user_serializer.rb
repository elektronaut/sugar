class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :realname, :latitude, :longitude, :inviter_id
  attributes :last_active, :created_at, :description, :admin
  attributes :moderator, :user_admin
  attributes :location, :gamertag, :twitter, :flickr, :instagram, :website, :sony
  attributes :msn, :gtalk, :last_fm, :facebook_uid, :banned_until

  attributes :active, :banned
end