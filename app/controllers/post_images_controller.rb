class PostImagesController < ApplicationController
  include DynamicImage::Controller

  caches_page :show, :uncropped, :original

  private

  def model
    PostImage
  end
end
