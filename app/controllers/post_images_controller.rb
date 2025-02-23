# frozen_string_literal: true

class PostImagesController < ApplicationController
  include DynamicImage::Controller

  private

  def model
    PostImage
  end
end
