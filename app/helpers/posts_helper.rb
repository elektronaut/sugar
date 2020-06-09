# frozen_string_literal: true

module PostsHelper
  def emojify(content)
    return if content.blank?

    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      emoji = Emoji.find_by_alias(Regexp.last_match(1))
      if emoji
        emoji_tag(emoji, alt: Regexp.last_match(1))
      else
        match
      end
    end.html_safe
  end

  def emoji_tag(emoji, alt:)
    tag(:img,
        alt: alt,
        class: "emoji",
        src: emoji_path(emoji),
        style: "vertical-align:middle",
        width: 16, height: 16)
  end

  def format_post(content, user)
    emojify(meify(content, user))
  end

  def meify(string, user)
    string.gsub(%r{(^|<\w+\s?/?>|\s)/me}) do
      Regexp.last_match(1).to_s + profile_link(user, nil, class: :poster)
    end.html_safe
  end

  def render_post(string)
    Renderer.render(string)
  end
end
