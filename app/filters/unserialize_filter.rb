# encoding: utf-8

class UnserializeFilter < Filter
  def process(post)
    parser = Nokogiri::HTML::DocumentFragment.parse(post)
    parser.search("base64serialized").each do |element|
      element.swap Base64.strict_decode64(element.content)
    end
    parser.to_html
  end
end
