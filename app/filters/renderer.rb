class Renderer
  class << self
    def filters(format)
      [
        AutolinkFilter,
        (format == "markdown" ? MarkdownFilter : SimpleFilter),
        ImageFilter,
        CodeFilter,
        SanitizeFilter
      ]
    end

    def render(post, options={})
      options[:format] ||= "markdown"
      filters(options[:format]).inject(post) { |str, filter| filter.new(str).to_html }.html_safe
    end
  end
end
