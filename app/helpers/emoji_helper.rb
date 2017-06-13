# encoding: utf-8

module EmojiHelper
  def emoji_path(emoji)
    if File.exist?(
         Rails.root.join("public", "images", "emoji", emoji.image_filename)
       )
      image_path("emoji/#{emoji.image_filename}", skip_pipeline: true)
    else
      image_path("emoji/#{emoji.image_filename}")
    end
  end
end
