# encoding: utf-8

require "digest/md5"

module AvatarsHelper
  def gravatar_url(email, options = {})
    options = {
      size: 24
    }.merge(options)
    hash = Digest::MD5.hexdigest(email)
    "https://secure.gravatar.com/avatar/#{hash}" \
      "?s=#{options[:size]}&r=x&d=identicon"
  end

  def avatar_image_tag(user)
    if user.avatar
      dynamic_image_tag(user.avatar, { crop: true }.merge(avatar_options(user)))
    elsif user.email?
      image_tag(gravatar_url(user.email, size: 96), avatar_options(user))
    else
      image_tag(
        gravatar_url("#{user.id}@#{request.host}", size: 96),
        avatar_options(user)
      )
    end
  end

  private

  def avatar_options(user)
    {
      size:  "96x96",
      alt:   user.username,
      class: "avatar-image"
    }
  end
end
