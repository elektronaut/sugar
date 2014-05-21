# encoding: utf-8

class MarkdownRenderer < Redcarpet::Render::HTML
  def preprocess(document)
    document = normalize_newlines(document)
    document = escape_leading_gts_without_space(document)
    document = separate_adjacent_blockquotes(document)
  end

  def postprocess(document)
    document.gsub("<div class=\"strip-me\"></div>\n\n", "")
  end

  private

  def normalize_newlines(document)
    document.gsub(/\r\n?/, "\n")
  end

  def separate_adjacent_blockquotes(document)
    document.gsub(/[\n]+\n(?=[\s]*>)/, "\n\n<div class=\"strip-me\"></div>\n\n")
  end

  def escape_leading_gts_without_space(document)
    document.gsub(/^([\s]*)([>]+)([^\s>])/) { $1 + ("&gt;" * $2.length) + $3 }
  end
end
