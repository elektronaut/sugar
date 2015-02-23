# encoding: utf-8

class MarkdownCodeFilter < Filter
  def process(post)
    markdown_code_blocks(post)
  end

  protected

  def markdown_code_blocks(str)
    str.gsub(/```([\w\d_]*)\r?\n(.*?)```(?:$|(\r?\n)+)/m) do |code_block|
      html = MarkdownFilter.new(code_block).to_html.strip
      serialized = Base64.strict_encode64(html)
      "<base64serialized>#{serialized}</base64serialized>"
    end
  end
end
