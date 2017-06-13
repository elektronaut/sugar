# encoding: utf-8

module PostsHelper
  def emojify(content)
    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      emoji = Emoji.find_by_alias(Regexp.last_match(1))
      if emoji
        "<img alt=\"#{Regexp.last_match(1)}\" class=\"emoji\" src=\"" +
          emoji_path(emoji) +
          '" style="vertical-align:middle" width="16" height="16" />'
      else
        match
      end
    end.html_safe if content.present?
  end

  def format_post(content, user)
    emojify(meify(content, user))
  end

  def meify(string, user)
    string.gsub(%r{(^|\<[\w]+\s?/?\>|[\s])/me}) do
      Regexp.last_match(1).to_s + profile_link(user, nil, class: :poster)
    end.html_safe
  end

  def render_post(string)
    Renderer.render(string)
  end
end
