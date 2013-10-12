# encoding: utf-8

class CodeFilter < Filter

  def process(post)
    parser = Nokogiri::HTML::DocumentFragment.parse(post)

    parser.search("code").each do |element|
      # Change language attribute to class
      unless element.attributes["language"].blank?
        element.set_attribute "class", element.attributes["language"]
        element.remove_attribute "language"
      end

      # Wrap it in a <pre> if it has a class
      if element.attributes["class"] && element.parent.name != "pre"
        element.swap("<pre>#{element.to_html}</pre>")
      end
    end

    parser.to_html
  end

end
