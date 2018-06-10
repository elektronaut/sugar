# frozen_string_literal: true

class AutolinkFilter < Filter
  def process(post)
    post.gsub(%r{(^|\s)((ftp|https?)://[^\s]+\b/?)}) do
      space = Regexp.last_match(1)
      match = Regexp.last_match(2)
      uri = URI.extract(Regexp.last_match(2)).try(:first)
      space + match.gsub(uri, autolink(uri))
    end
  end

  private

  def autolink(url)
    if url.match?(/.(jpg|jpeg|gif|png|gifv)$/i)
      '<img src="' + url.gsub(/\.gifv$/, ".gif") + '">'
    elsif url.match?(twitter_expression)
      twitter_embed(url)
    elsif url.match?(%r{(https?://(www\.)?instagram\.com/p\/[^/]+/)})
      instagram_embed(url)
    else
      "<a href=\"#{url}\">#{url}</a>"
    end
  end

  def oembed(base_url, url)
    response = JSON.parse(HTTParty.get("#{base_url}?url=#{url}").body)
    response["html"]
  rescue StandardError => e
    logger.error "Unexpected connection error #{e.inspect}"
    url
  end

  def instagram_embed(url)
    oembed("https://api.instagram.com/oembed", url)
  end

  def twitter_embed(url)
    oembed("https://publish.twitter.com/oembed", normalize_twitter_url(url))
  end

  def twitter_expression
    %r{^https?://(mobile\.)?twitter\.com/(([\w\d_]+)/)?status(es)?/([\d]+)}
  end

  def normalize_twitter_url(url)
    if url.match?(%r{^https?://twitter\.com/([\w\d_]+)/status/([\d]+)})
      url
    else
      id = url.match(%r{/([\d]+)$})[1]
      "https://twitter.com/twitter/status/#{id}"
    end
  end
end
