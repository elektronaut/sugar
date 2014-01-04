class UploadsController < ApplicationController

  requires_authentication
  requires_user

  before_action :require_s3

  respond_to :xml, :json

  def create
    response = {}
    upload = Upload.new(upload_params[:file])

    if upload.valid?
      upload.save
      response = {
        name: upload.name,
        type: upload.mime_type,
        url:  upload.url
      }
    end

    respond_with(response) do |format|
      format.json { render json: response }
      format.xml  { render xml: response }
    end
  end

  private

  def upload_params
    params.require(:upload).permit(:file)
  end
end
