# frozen_string_literal: true

class AutolinkFilter < Filter
  include ActionView::Helpers::TagHelper

  def process(post)
    post.gsub(%r{(^|\s)((ftp|https?)://[^\s]+/?(\s|$))}) do
      space = Regexp.last_match(1)
      match = Regexp.last_match(2)
      uri = URI.extract(Regexp.last_match(2)).try(:first)
      space + match.gsub(uri, autolink(uri))
    end
  end

  private

  def autolink(url)
    if url.match?(/.(jpg|jpeg|gif|png|gifv)$/i)
      "<img src=\"#{url.gsub(/\.gifv$/, '.gif')}\">"
    elsif url.match?(twitter_expression)
      oembed(normalize_twitter_url(url))
    elsif oembeddable?(url)
      oembed(url)
    else
      link(url)
    end
  end

  def link(url)
    "<a href=\"#{url}\">#{url}</a>"
  end

  def oembeddable?(url)
    OEmbed::Providers.find(url) ? true : false
  end

  def oembed(url)
    embed = OEmbed::Providers.get(url).html.strip
    "<div class=\"embed\" data-oembed-url=\"#{url}\">#{embed}</div>"
  rescue StandardError => e
    logger.error "Unexpected connection error #{e.inspect}"
    link(url)
  end

  def twitter_expression
    %r{^https?://(mobile\.)?twitter\.com/(([\w\d_]+)/)?status(es)?/(\d+)}
  end

  def normalize_twitter_url(url)
    url = url.gsub(%r{/photo/\d+}, "") # Ignore photo path
             .gsub(%r{/mediaViewer\?(.*)\b}, "")

    return url if url.match?(%r{^https?://twitter\.com/([\w\d_]+)/status/(\d+)})
    return url unless url.match?(%r{/(\d+)$})

    id = url.match(%r{/(\d+)$})[1]
    "https://twitter.com/twitter/status/#{id}"
  end
end
