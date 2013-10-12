# encoding: utf-8

class MarkdownRenderer < Redcarpet::Render::HTML
  def preprocess(document)
    escape_leading_gts_without_space(document)
  end

  def escape_leading_gts_without_space(document)
    document.gsub(/^([\s]*)([>]+)([^\s>])/) { $1 + ("&gt;" * $2.length) + $3 }
  end
end
