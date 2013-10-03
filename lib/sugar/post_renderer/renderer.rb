# encoding: utf-8

module Sugar
  module PostRenderer
    class Renderer

      def initialize(post)
        @post = post
      end

      def filters
        [
          Sugar::PostRenderer::Markdown,
          Sugar::PostRenderer::Images,
          Sugar::PostRenderer::Code,
          Sugar::PostRenderer::Sanitizer
        ]
      end

      def to_html
        @post = @post.strip

        # Autotag images
        @post.gsub!(/(^|\s)(((ftp|https?):)?\/\/[^\s]+\.(png|jpg|jpeg|gif)\b?)/) do
          "#{$1}<img src=\"#{$2}\">"
        end

        filters.each do |filter|
          @post = filter.new(@post).to_html
        end
        @post.html_safe
      end

    end
  end
end