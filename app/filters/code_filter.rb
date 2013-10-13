# encoding: utf-8

class CodeFilter < Filter

  def process(post)
    parser = Nokogiri::HTML::DocumentFragment.parse(post)

    parser.search("code").each do |element|
      change_language_attribute(element)
      wrap_in_pre(element)
      syntax_highlight(element)
    end

    parser.to_html
  end

  protected

  def change_language_attribute(element)
    # Old posts have language specified in a "language" attribute,
    # let's change that to class.
    unless element.attributes["language"].blank?
      element.set_attribute "class", element.attributes["language"]
      element.remove_attribute "language"
    end
  end

  def wrap_in_pre(element)
    # If the element has a class, let's assume it is a code block
    # and wrap it in a <pre>
    if element.attributes["class"] && element.parent.name != "pre"
      element.swap("<pre>#{element.to_html}</pre>")
    end
  end

  def syntax_formatter
    Rouge::Formatters::HTML.new(css_class: "highlight")
  end

  def syntax_highlight(element)
    if element.parent.name == "pre"
      code = unescape(element.inner_html)
      language = element.attributes["class"].try(&:value)
      lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText
      element.parent.swap(syntax_formatter.format(lexer.lex(code)))
    end
  end

  def unescape(str)
    str.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&")
  end

end
