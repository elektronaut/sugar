# encoding: utf-8

class CodeFilter < Filter

  def process(post)
    parser = Nokogiri::HTML::DocumentFragment.parse(markdown_code_blocks(post))

    parser.search("code").each do |element|
      code = element.content
      syntax_highlight(element, code)
    end

    parser.search("pre").each do |element|
      if element.attributes["class"].try(:value) =~ /\bhighlight\b/
        base64_serialize(element)
      end
    end

    parser.to_html
  end

  protected

  def base64_serialize(element)
    serialized = Base64.strict_encode64(element.to_html)
    element.swap("<base64serialized>#{serialized}</base64serialized>")
  end

  def markdown_code_blocks(str)
    str.gsub(/```([\w\d_]*)\r?\n(.*?)```(?:$|(\r?\n)+)/m) do |code_block|
      MarkdownFilter.new(code_block).to_html.strip
    end
  end

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
