class Upload
  attr_accessor :file, :options

  class << self
    def create(file, options={})
      upload = self.new(file, options)
      if upload.valid?
        upload.save
      end
      upload
    end
  end

  def initialize(file, options={})
    @file = file
    @options = options
  end

  def s3_bucket
    @s3_bucket ||= AWS::S3.new(
      access_key_id:     Sugar.config.amazon_aws_key,
      secret_access_key: Sugar.config.amazon_aws_secret,
      region:            'us-east-1'
    ).buckets[Sugar.config.amazon_s3_bucket]
  end

  def s3_object
    s3_bucket.objects[filename]
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
    unless exists?
      file.rewind
      s3_object.write(file.read, acl: :public_read)
    end
  end

  def exists?
    s3_object.exists?
  end

  def url
    s3_object.public_url.to_s
  end

  def valid?
    file && valid_mime_type?
  end

  private

  def valid_mime_type?
    mime_type =~ /^image\/(png|jpeg|gif)$/
  end
end