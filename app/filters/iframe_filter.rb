# encoding: utf-8

class IframeFilter < Filter

  HTTPS_WHITELIST = [
    /\Ahttps?:\/\/([\w\d\-]+\.)?youtube\.(com|com\.br|fr|jp|nl|pl|es|ie|co\.uk)\//,
    /\Ahttps?:\/\/youtu\.be\//,
    /\Ahttps?:\/\/vimeo\.com\//,
    /\Ahttps?:\/\/soundcloud\.com\//
  ]

  def process(post)
    @post = post
    rewrite_for_https_support!
    parser.to_html
  end

  private

  def parser
    @parser ||= Nokogiri::HTML::DocumentFragment.parse(@post)
  end

  def rewrite_for_https_support!
    parser.search("iframe").each do |iframe|
      if src = iframe.try(:attributes).try(:[], 'src').try(:value)
        if HTTPS_WHITELIST.find { |expr| src =~ expr }
          iframe.set_attribute 'src', src.gsub(/\Ahttps?:\/\//, "//")
        end
      end
    end
  end
end
