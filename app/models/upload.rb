class Upload
  attr_accessor :file, :options

  def initialize(file, options={})
    @file = file
    @options = options
  end

  def establish_connection!
    AWS::S3::Base.establish_connection!(
      :access_key_id     => Sugar.config(:amazon_aws_key),
      :secret_access_key => Sugar.config(:amazon_aws_secret)
    )
  end

  def name
    options[:name] || file.original_filename
  end

  def mime_type
    @mime_type ||= FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(file.path)
  end

  def filename
    [hexdigest, name.split(".").last].join(".")
  end

  def hexdigest
    @hexdigest ||= Digest::SHA1.hexdigest(file.read)
  end

  def save
    establish_connection!
    unless exists?
      AWS::S3::S3Object.store(
        filename,
        open(file),
        Sugar.config(:amazon_s3_bucket),
        access: :public_read
      )
    end
  end

  def exists?
    AWS::S3::S3Object.exists?(filename, Sugar.config(:amazon_s3_bucket))
  end

  def url
    establish_connection!
    AWS::S3::S3Object.url_for(
      filename,
      Sugar.config(:amazon_s3_bucket),
      authenticated: false,
      use_ssl: true
    )
  end

  def valid?
    file && valid_mime_type?
  end

  private

  def valid_mime_type?
    mime_type =~ /^image\/(png|jpeg|gif)$/
  end

end