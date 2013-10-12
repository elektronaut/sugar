# encoding: utf-8

require 'digest/md5'

module AvatarsHelper

  def gravatar_url(email, options={})
    options = {
      size: 24
    }.merge(options)
    hash = Digest::MD5.hexdigest(email)
    base_url = request.ssl? ? 'https://secure.gravatar.com' : 'http://www.gravatar.com'
    "#{base_url}/avatar/#{hash}?s=#{options[:size]}&r=x&d=identicon"
  end

  # Generates avatar image tag for a user
  def avatar_image_tag(user, size='32', html_options={})
    html_options = {
      size: "#{size}x#{size}",
      alt:  user.username
    }.merge(html_options)
    if user.avatar_url?
      image_tag user.avatar_url, html_options
    elsif user.email?
      image_tag gravatar_url(user.email, size: size), html_options
    else
      image_tag gravatar_url("#{user.id}@#{request.host}", size: size), html_options
    end
  end

end