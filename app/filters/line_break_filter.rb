# encoding: utf-8

class LineBreakFilter < Filter
  def process(post)
    convert_line_breaks(post)
  end

  private

  def convert_line_breaks(str)
    str.gsub(/[\r]?\n/, "<br>\n")
  end
end
