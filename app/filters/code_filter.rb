# encoding: utf-8

class CodeFilter < Filter
  def process(post)
    parser = Nokogiri::HTML::DocumentFragment.parse(post)

    parser.search("code").each do |element|
      code = element.content
      syntax_highlight(element, code)
    end

    parser.to_html
  end

  protected

  def syntax_formatter
    Rouge::Formatters::HTML.new(css_class: "highlight")
  end

  def syntax_highlight(element, code)
    if element.parent.name == "pre"
      language = element.attributes["class"].try(&:value)
      lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText
      element.parent.swap(syntax_formatter.format(lexer.lex(code)))
    end
  end
end
