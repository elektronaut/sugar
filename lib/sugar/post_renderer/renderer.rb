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
        filters.inject(@post) { |post, filter| filter.new(post).to_html }.html_safe
      end

    end
  end
end