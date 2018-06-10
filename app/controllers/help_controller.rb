# frozen_string_literal: true

class HelpController < ApplicationController
  def index
    redirect_to keyboard_help_url
  end

  def code_of_conduct
    @code_of_conduct = Sugar.config.code_of_conduct
  end

  def keyboard; end
end
