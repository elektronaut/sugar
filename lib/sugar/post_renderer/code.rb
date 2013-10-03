# encoding: utf-8

module Sugar
  module PostRenderer
    class Code

      def initialize(post)
        @post = post
      end

      def to_html
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

      private

      def parser
        @parser ||= Nokogiri::HTML::DocumentFragment.parse(@post)
      end

    end
  end
end