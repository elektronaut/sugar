# encoding: utf-8

class AutolinkFilter < Filter
  def process(post)
    post.gsub(/(^|\s)((ftp|https?):\/\/[^\s]+\b\/?)/) do
      space, match = $1, $2
      uri = URI.extract($2).try(:first)
      space + match.gsub(uri, autolink(uri))
    end
  end

  private

  def autolink(url)
    if url =~ /imgur.*\.(gif)$/i
      "<video loop controls autoplay><source src=\"" + url.sub(/\.gif/, ".mp4") + "\" type=\"video/mp4\"></video>"
    elsif url =~ /.(jpg|jpeg|gif|png)$/i
      "<img src=\"#{url}\">"
    elsif url =~ /\.(gifv)$/i
      "<video loop controls autoplay><source src=\"" + url.sub(/\.gifv/, ".mp4") + "\" type=\"video/mp4\"></video>"
    else
      "<a href=\"#{url}\">#{url}</a>"
    end
  end
end
