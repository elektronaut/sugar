# encoding: utf-8

module Sugar
  module PostRenderer
    class Images

      def initialize(post)
        @post = post
      end

      def to_html
        parser.css('img').each do |element|
          if element.attributes && !element.attributes['src'].blank?
            url = element.attributes['src']
            if element.attributes['width'].blank? || element.attributes['height'].blank?
              if dimensions = FastImage.size(url, timeout: 2.0)
                width, height = dimensions
                element.set_attribute "width", width.to_s
                element.set_attribute "height", height.to_s
              end
            end
          end
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