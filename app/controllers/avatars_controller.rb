# frozen_string_literal: true

class AvatarsController < ApplicationController
  include DynamicImage::Controller

  caches_page :show, :uncropped, :original

  private

  def model
    Avatar
  end
end
