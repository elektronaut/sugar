class UploadsController < ApplicationController
  requires_authentication
  requires_user

  respond_to :xml, :json

  def create
    response = {}
    post_image = PostImage.new(file: upload_params[:file])

    if post_image.valid?
      hash = Dis::Storage.file_digest(upload_params[:file])
      if PostImage.where(content_hash: hash).any?
        post_image = PostImage.where(content_hash: hash).first
      else
        post_image.save
      end

      response = {
        name: post_image.filename,
        type: post_image.content_type,
        embed: "[image:#{post_image.id}:#{post_image.content_hash}]"
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
