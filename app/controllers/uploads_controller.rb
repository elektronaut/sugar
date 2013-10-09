class UploadsController < ApplicationController

  requires_authentication
  requires_user

  before_filter :require_s3
  before_filter :establish_s3_connection

  respond_to :xml, :json

  def create
    response = {}
    file = upload_params[:file]

    if file && is_valid_file?(file)
      url = upload_to_s3(file)
      response = {
        name: file.original_filename,
        type: mime_type(file),
        url:  url
      }
    end

    respond_with(response) do |format|
      format.json { render json: response }
      format.xml { render xml: response }
    end
  end

  private

  def mime_type(file)
    FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(file.path)
  end

  def is_valid_file?(file)
    mime_type(file) =~ /^image\/(png|jpeg|gif)$/
  end

  def upload_to_s3(file)
    hash     = Digest::SHA1.hexdigest(file.read)
    filename = [hash, file.original_filename.split(".").last].join(".")

    unless AWS::S3::S3Object.exists?(filename, Sugar.config(:amazon_s3_bucket))
      AWS::S3::S3Object.store(filename, open(file), Sugar.config(:amazon_s3_bucket), access: :public_read)
    end

    AWS::S3::S3Object.url_for(filename, Sugar.config(:amazon_s3_bucket), authenticated: false, use_ssl: true)
  end

  def require_s3
    unless Sugar.aws_s3?
      redirect_to root_url and return
    end
  end

  def establish_s3_connection
    AWS::S3::Base.establish_connection!(
      :access_key_id     => Sugar.config(:amazon_aws_key),
      :secret_access_key => Sugar.config(:amazon_aws_secret)
    )
  end

  def upload_params
    params.require(:upload).permit(:file)
  end
end
