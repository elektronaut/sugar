# encoding: utf-8

class SimpleFilter < Filter
  def process(post)
    convert_line_breaks(escape_angle_brackets(strip(post)))
  end

  private

  def convert_line_breaks(str)
    str.gsub(/[\r]?\n/, "<br>\n")
  end

  def escape_angle_brackets(str)
    str.
      gsub(Regexp.new("<(?!/|" + html_tags.join("|") + ")"), "&lt;").
      gsub(Regexp.new("(?<!\"|'|" + html_tags.join("|") + ")>"), "&gt;")
  end

  def strip(post)
    post.gsub(/\A[\s\n]*/, "").gsub(/[\s\n]*\Z/, "")
  end

  def html_tags
    %w{
      a abbr address area article aside audio b base bdi bdo blockquote
      body br button canvas caption cite code col colgroup data datalist
      dd del details dfn div dl dt em embed fieldset figcaption figure
      footer form h1 h2 h3 h4 h5 h6 head header hr html i iframe img
      input ins kbd keygen label legend li link main map mark math menu
      menuitem meta meter nav noscript object ol optgroup option output
      p param pre progress q rp rt ruby s samp script section select small
      source span strong style sub summary svg table tbody td textarea tfoot
      th thead time title tr track u ul var video wbr
      allowfullscreen base64serialized
    }
  end
end
