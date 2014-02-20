# encoding: utf-8

class LinkFilter < Filter

  HTTPS_WHITELIST = [
    /\Ahttps?:\/\/([\w\d\-]+\.)?youtube\.(com|com\.br|fr|jp|nl|pl|es|ie|co\.uk)\//,
    /\Ahttps?:\/\/youtu\.be\//,
    /\Ahttps?:\/\/vimeo\.com\//,
    /\Ahttps?:\/\/soundcloud\.com\//
  ]

  def process(post)
    @post = post
    relativize_local_links!
    rewrite_for_https_support!
    parser.to_html
  end

  private

  def local_domains
    Sugar.config.domain_names.try(:strip).try(:split, /\s*,\s*/)
  end

  def parser
    @parser ||= Nokogiri::HTML::DocumentFragment.parse(@post)
  end

  def relativize_local_links!
    parser.search("a").each do |link|
      if href = link.try(:attributes).try(:[], 'href').try(:value)
        host = URI.parse(href).host
        if local_domains.find { |d| host == d }
          link.set_attribute 'href', href.gsub(Regexp.new("(https?:)?\/\/" + Regexp.escape(host)), "")
        end
      end
    end
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
