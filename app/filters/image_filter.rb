# encoding: utf-8

class ImageFilter < Filter

  def process(post)
    parser = Nokogiri::HTML::DocumentFragment.parse(post)
    parser.css('img').each do |element|
      if element.attributes && !element.attributes['src'].blank?
        url = element.attributes['src']
        if element.attributes['width'].blank? || element.attributes['height'].blank?
          if dimensions = FastImage.size(url, timeout: 2.0)
            width, height = dimensions
            element.set_attribute "width", width.to_s
            element.set_attribute "height", height.to_s
          end
        end
      end
    end
    parser.to_html
  end

end
