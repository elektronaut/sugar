# encoding: utf-8

module Sugar
  module PostRenderer
    class Markdown

      def initialize(post)
        @post = post
      end

      def to_html
        markdown.render(@post)
      end

      private

      def markdown_renderer
        @markdown_renderer ||= Redcarpet::Render::HTML.new(
          hard_wrap: true
        )
      end

      def markdown
        @markdown ||= Redcarpet::Markdown.new(
          markdown_renderer,
          no_intra_emphasis:   true,
          fenced_code_blocks:  true,
          autolink:            true,
          strikethrough:       true,
          lax_spacing:         true,
          space_after_headers: true
        )
      end

    end
  end
end