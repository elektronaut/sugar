class AvatarsController < ApplicationController
  include DynamicImage::Controller

  private

  def model
    Avatar
  end
end
