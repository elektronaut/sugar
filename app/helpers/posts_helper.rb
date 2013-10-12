# encoding: utf-8

module PostsHelper

  def meify(string, user)
    string.gsub(/(^|\<[\w]+\s?\/?\>|[\s])\/me/){ $1.to_s + profile_link(user, nil, class: :poster) }.html_safe
  end

  def format_post(string)
    Sugar::PostRenderer.render(string)
  end

end