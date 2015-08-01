class PostImagesController < ApplicationController
  include DynamicImage::Controller

  private

  def model
    PostImage
  end
end
