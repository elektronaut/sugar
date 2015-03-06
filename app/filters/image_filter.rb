# encoding: utf-8

class ImageFilter < Filter
  def process(post)
    parser = Nokogiri::HTML::DocumentFragment.parse(post)
    parser.css("img").each do |element|
      process_image(element)
    end
    parser.to_html
  end

  private

  def has_src?(elem)
    elem.attributes && !elem.attributes["src"].blank?
  end

  def image_src(elem)
    if has_src?(elem)
      elem.attributes["src"].to_s
    end
  end

  def needs_dimensions?(elem)
    elem.attributes["width"].blank? ||
      elem.attributes["height"].blank?
  end

  def process_image(elem)
    url = image_src(elem)
    if url && needs_dimensions?(elem)
      if dimensions = FastImage.size(url, timeout: 2.0)
        width, height = dimensions
        elem.set_attribute "width", width.to_s
        elem.set_attribute "height", height.to_s
      end
    end
  end
end
