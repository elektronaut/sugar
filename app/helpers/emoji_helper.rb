# frozen_string_literal: true

module EmojiHelper
  def emoji_path(emoji)
    if Rails.public_path.join("images", "emoji", emoji.image_filename).exist?
      image_path("emoji/#{emoji.image_filename}", skip_pipeline: true)
    else
      image_path("emoji/#{emoji.image_filename}")
    end
  end
end
