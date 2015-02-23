# encoding: utf-8

class MarkdownFilter < Filter
  def process(post)
    markdown.render(post)
  end

  private

  def markdown_renderer
    @markdown_renderer ||= MarkdownRenderer.new(
      hard_wrap: true
    )
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(
      markdown_renderer,
      no_intra_emphasis:            true,
      fenced_code_blocks:           true,
      disable_indented_code_blocks: true,
      autolink:                     false,
      strikethrough:                true,
      lax_spacing:                  true,
      space_after_headers:          true
    )
  end
end
