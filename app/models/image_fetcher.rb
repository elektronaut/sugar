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
    fetch_tagged_images(
      fetch_markdown_images(
        fetch_autolinked_images(body)
      )
    )
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
      /((!\[[^\]]*\])(\((ftp|https?):\/\/[^\s]+\.(jpg|jpeg|gif|png)\b\/?)\))/i
    ) do
      full, match = $1, $3
      uri = extract_uri(match)
      if post_image = fetch_image(uri)
        embed_image(post_image)
      else
        full
      end
    end
  end

  def fetch_tagged_images(str)
    parser = Nokogiri::HTML::DocumentFragment.parse(str)
    parser.css("img").each do |element|
      post_image = fetch_image(elem_src(element))
      if post_image
        [
          element.to_s,
          element.to_s.gsub(/>$/, " />") # Nokogiri botches self-closing tags
        ].each do |pattern|
          str = str.gsub(pattern, embed_image(post_image))
        end
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
    return nil unless host_whitelist?(URI.parse(uri).hostname)
    find_image(uri) || create_image(uri)
  end

  def host_whitelist?(hostname)
    %w{i.imgur.com m.imgur.com}.include?(hostname)
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

  def create_tempfile(data)
    Tempfile.new("post-image-temp").tap do |f|
      f.binmode
      f.write data
      f.rewind
    end
  end

  def embed_image(post_image)
    "[image:#{post_image.id}:#{post_image.content_hash}]"
  end

  def uploaded_file(request)
    Rack::Test::UploadedFile.new(
      create_tempfile(request.parsed_response),
      request.content_type
    )
  end

  def create_image(uri)
    request = HTTParty.get(uri)
    image = PostImage.create(
      data: uploaded_file(request),
      content_type: request.content_type,
      filename: filename(uri),
      original_url: uri
    )
    if image.valid?
      image
    else
      nil
    end
  end

  def filename(uri)
    URI.parse(uri).path.split("/").last
  end
end
