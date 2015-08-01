class ImageFetcher
  attr_accessor :body

  class << self
    def fetch(body)
      new(body).fetch
    end
  end

  def initialize(body)
    @body = body
  end

  def fetch
    str = fetch_autolinked_images(body)
    str = fetch_markdown_images(str)
    str = fetch_tagged_images(str)
    str
  end

  private

  def fetch_autolinked_images(str)
    str.gsub(/(^|\s)((ftp|https?):\/\/[^\s]+\.(jpg|jpeg|gif|png)\b\/?)/i) do
      pre, match = $1, $2
      uri = extract_uri(match)
      if post_image = fetch_image(uri)
        pre + match.gsub(uri, embed_image(post_image))
      else
        pre + match
      end
    end
  end

  def fetch_markdown_images(str)
    str.gsub(
      /(!\[[^\]]*\])(\((ftp|https?):\/\/[^\s]+\.(jpg|jpeg|gif|png)\b\/?)\)/i
    ) do
      match = $2
      uri = extract_uri(match)
      if post_image = fetch_image(uri)
        embed_image(post_image)
      else
        match
      end
    end
  end

  def fetch_tagged_images(str)
    parser = Nokogiri::HTML::DocumentFragment.parse(str)
    parser.css("img").each do |element|
      post_image = fetch_image(elem_src(element))
      if post_image
        str = str.gsub(element.to_s, embed_image(post_image))
      end
    end
    str
  end

  def extract_uri(str)
    URI.extract(str).try(:first)
  end

  def fetch_image(uri)
    return nil unless uri
    # Only fetch imgurl URLs for now
    return nil unless URI.parse(uri).hostname == "i.imgur.com"
    find_image(uri) || create_image(uri)
  end

  def find_image(uri)
    PostImage.where(original_url: uri).first
  end

  def has_src?(elem)
    elem.attributes && !elem.attributes["src"].blank?
  end

  def elem_src(elem)
    if has_src?(elem)
      elem.attributes["src"].to_s
    end
  end

  def content_type(uri)
    name = filename(uri)
    if name =~ /\.gif/i
      "image/gif"
    elsif name =~ /\.png/i
      "image/png"
    else
      "image/jpeg"
    end
  end

  def create_tempfile(uri)
    Tempfile.new("post-image-temp").tap do |f|
      f.binmode
      f.write HTTParty.get(uri).parsed_response
    end
  end

  def embed_image(post_image)
    "[image:#{post_image.id}:#{post_image.content_hash}]"
  end

  def fetch_file(uri)
    Rack::Test::UploadedFile.new(
      create_tempfile(uri),
      content_type(uri)
    )
  end

  def create_image(uri)
    PostImage.create(
      data: fetch_file(uri),
      content_type: content_type(uri),
      filename: filename(uri),
      original_url: uri
    )
  end

  def filename(uri)
    URI.parse(uri).path.split("/").last
  end
end
