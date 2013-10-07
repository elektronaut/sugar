require_relative 'post_renderer/filter'
require_relative 'post_renderer/autolink'
require_relative 'post_renderer/code'
require_relative 'post_renderer/images'
require_relative 'post_renderer/markdown'
require_relative 'post_renderer/markdown_renderer'
require_relative 'post_renderer/sanitizer'
require_relative 'post_renderer/simple'

module Sugar
  module PostRenderer
    class << self
      def filters(format)
        [
          Sugar::PostRenderer::Autolink,
          (format == "markdown" ? Sugar::PostRenderer::Markdown : Sugar::PostRenderer::Simple),
          Sugar::PostRenderer::Images,
          Sugar::PostRenderer::Code,
          Sugar::PostRenderer::Sanitizer
        ]
      end

      def render(post, options={})
        options[:format] ||= "markdown"
        filters(options[:format]).inject(post) { |str, filter| filter.new(str).to_html }.html_safe
      end
    end
  end
end