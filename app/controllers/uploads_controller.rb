class UploadsController < ApplicationController

  requires_authentication
  requires_user

  respond_to :xml, :json

  def create
    render :json => 'OK'
  end
end
