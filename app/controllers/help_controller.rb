# encoding: utf-8

class HelpController < ApplicationController
  def index
    redirect_to help_page_path('keyboard') and return
  end

  def show
    @page = params[:page].gsub(/[^\w\d_\-]/, '')
    render template: "help/#{@page}"
  end
end
