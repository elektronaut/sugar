# frozen_string_literal: true

module IconsHelper
  def icon_tags
    regular_icon_tags +
      apple_icon_tags +
      windows_icon_tags
  end

  private

  def favicon_tag(path, type)
    tag(:link, rel: "icon", href: image_path(path), type: type)
  end

  def regular_icon_tags
    favicon_tag("icons/favicon.ico", "image/x-icon") +
      favicon_tag("icons/favicon.png", "image/png")
  end

  def apple_icon_tags
    safe_join(%w[57 72 114 144 60 120 76 152].map do |s|
      tag(:link,
          rel: "apple-touch-icon-precomposed",
          sizes: "#{s}x#{s}",
          href: image_path("icons/apple-touch-icon-#{s}x#{s}.png"))
    end)
  end

  def windows_icon_tags
    safe_join({
      smalltile: "square70x70logo",
      mediumtile: "square150x150logo",
      widetile: "wide310x150logo",
      largetile: "square310x310logo"
    }.map do |f, n|
      tag(:meta,
          name: "msapplication-#{n}",
          content: image_path("icons/#{f}.png"))
    end)
  end
end
