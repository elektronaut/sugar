# encoding: utf-8

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
    if url =~ /.(jpg|jpeg|gif|png)$/i
      "<img src=\"#{url}\">"
    elsif url =~ /\.(gifv)$/i
      '<img src="' + url.gsub(/\.gifv$/, ".gif") + '">'
    elsif url =~ /(https?:\/\/(www\.)?instagram\.com\/p\/[^\/]+\/)/
      instagram_embed(url)
    else
      "<a href=\"#{url}\">#{url}</a>"
    end
  end

  def instagram_embed(url)
    api_url = "https://api.instagram.com/oembed?url=#{url}"
    response = JSON.parse(HTTParty.get(api_url).body)
    response["html"]
  rescue StandardError => e
    logger.error "Unexpected connection error #{e.inspect}"
    url
  end
end
