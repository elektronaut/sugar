# encoding: utf-8

class AdminController < ApplicationController

  requires_admin

  def configuration
    if request.post? && params[:config]
      Sugar.update_configuration(params[:config])
    end
  end
end
