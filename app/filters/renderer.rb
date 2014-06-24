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
              CodeFilter
            ]
          when "html"
            [
              CodeFilter,
              SimpleFilter
            ]
          end
        ),
        ImageFilter,
        LinkFilter,
        UnserializeFilter,
        SanitizeFilter,
      ].flatten
    end

    def render(post, options={})
      options[:format] ||= "markdown"
      filters(options[:format]).inject(post) { |str, filter| filter.new(str).to_html }.html_safe
    end
  end
end
