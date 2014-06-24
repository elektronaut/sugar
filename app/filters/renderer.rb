class Renderer
  class << self
    def filters(format)
      [
        AutolinkFilter,
        (
          case format
          when "markdown"
            [
              MarkdownFilter,
              CodeFilter,
            ]
          when "html"
            [
              MarkdownCodeFilter,
              SimpleFilter,
              UnserializeFilter,
              CodeFilter,
            ]
          end
        ),
        ImageFilter,
        LinkFilter,
        SanitizeFilter,
      ].flatten
    end

    def render(post, options={})
      options[:format] ||= "markdown"
      filters(options[:format]).inject(post) { |str, filter| filter.new(str).to_html }.html_safe
    end
  end
end
