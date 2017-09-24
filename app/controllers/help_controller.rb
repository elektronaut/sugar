# encoding: utf-8

class HelpController < ApplicationController
  def index
    redirect_to help_page_path("keyboard")
  end

  def show
    @page = params[:page]
    case @page
    when "keyboard"
      render template: "help/keyboard"
    end
  end
end
