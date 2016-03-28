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
    else
      "<a href=\"#{url}\">#{url}</a>"
    end
  end
end
