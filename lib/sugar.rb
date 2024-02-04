# frozen_string_literal: true

module Sugar
  class << self
    def aws_s3?
      if ENV.fetch("S3_BUCKET", nil) &&
         ENV.fetch("S3_KEY_ID", nil) &&
         ENV["S3_SECRET"]
        true
      else
        false
      end
    end

    def config(_key = nil, *_args)
      @config ||= Configuration.new.tap(&:load)
    end

    def public_browsing?
      config.public_browsing
    end
  end
end
