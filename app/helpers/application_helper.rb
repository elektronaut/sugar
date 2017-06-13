# encoding: utf-8

module ApplicationHelper
  include AvatarsHelper
  include CurrentUserHelper
  include EmojiHelper
  include ExchangesHelper
  include IconsHelper
  include LayoutHelper
  include PaginationHelper
  include PostsHelper
  include DynamicImage::Helper

  def facebook_oauth_url(redirect_uri)
    "https://www.facebook.com/dialog/oauth?client_id=" \
      "#{Sugar.config.facebook_app_id}" \
      "&redirect_uri=#{redirect_uri}" \
      "&scope=email"
  end

  def pretty_link(url)
    url = "http://" + url unless url =~ %r{^(f|ht)tps?://}
    url = url.gsub(%r{/$}, "") if url =~ %r{^(f|ht)tps?://[\w\d\-\.]*/$}
    link_to url.gsub(%r{^(f|ht)tps?://}, ""), url
  end

  def possessive(noun)
    (noun =~ /s$/) ? "#{noun}'" : "#{noun}'s"
  end

  # Generates a link to the users profile
  def profile_link(user, link_text = nil, options = {})
    if user
      link_text ||= user.username
      link_to(
        link_text,
        user_profile_path(id: user.username),
        { title: "#{possessive(user.username)} profile" }.merge(options)
      )
    else
      "Unknown"
    end
  end
end
