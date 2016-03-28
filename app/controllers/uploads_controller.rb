class UploadsController < ApplicationController
  requires_authentication
  requires_user

  respond_to :xml, :json

  def create
    post_image = find_or_create_post_image(upload_params[:file])
    response = post_image_response(post_image)

    respond_with(response) do |format|
      format.json { render json: response }
      format.xml  { render xml: response }
    end
  end

  private

  def find_or_create_post_image(file)
    post_image = PostImage.new(file: file)
    if post_image.valid?
      hash = Dis::Storage.file_digest(file)
      if PostImage.where(content_hash: hash).any?
        post_image = PostImage.where(content_hash: hash).first
      else
        post_image.save
      end
    end
    post_image
  end

  def post_image_response(post_image)
    return {} unless post_image.valid?
    {
      name: post_image.filename,
      type: post_image.content_type,
      embed: "[image:#{post_image.id}:#{post_image.content_hash}]"
    }
  end

  def upload_params
    params.require(:upload).permit(:file)
  end
end
