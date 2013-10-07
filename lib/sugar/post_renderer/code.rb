# encoding: utf-8

module Sugar
  module PostRenderer
    class Code < Sugar::PostRenderer::Filter

      def process(post)
        parser = Nokogiri::HTML::DocumentFragment.parse(post)
        parser.search('p > code').each do |element|
          if element.attributes && !element.attributes["language"].blank?
            element.set_attribute "class", element.attributes["language"]
            element.remove_attribute "language"
          else
            element.set_attribute "class", "plain"
          end
          element.parent.swap("<pre>#{element.to_html}</pre>")
        end
        parser.to_html
      end

    end
  end
end