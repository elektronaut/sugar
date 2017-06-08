class Renderer
  class << self
    def filters(format)
      [
        AutolinkFilter,
        format_filters(format),
        CodeFilter,
        ImageFilter,
        LinkFilter,
        PostImageFilter,
        SanitizeFilter
      ].flatten
    end

    def render(post, options = {})
      options[:format] ||= "markdown"
      filters(options[:format]).inject(post) do |str, filter|
        filter.new(str).to_html
      end.html_safe
    end

    private

    def format_filters(format)
      if format == "markdown"
        MarkdownFilter
      else
        [
          MarkdownCodeFilter,
          SimpleFilter,
          UnserializeFilter
        ]
      end
    end
  end
end
