# encoding: utf-8

class PostImageFilter < Filter
  include ActionView::Helpers::AssetTagHelper
  include DynamicImage::Helper
  include Rails.application.routes.url_helpers

  def process(post)
    post.gsub(/(\[image:([\d]+):([\w\d]+)\])/) do
      tag, id, content_hash = $1, $2, $3
      embed_image(id, content_hash) || tag
    end
  end

  private

  def embed_image(id, content_hash)
    image = PostImage.where(
      id: id,
      content_hash: content_hash
    ).first
    return nil unless image
    dynamic_image_tag(image)
  end
end
