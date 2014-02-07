# encoding: utf-8

class AdminController < ApplicationController

  requires_admin

  def configuration
    if request.post? && params[:config]
      Sugar.config.update(params[:config])
    end
  end
end
