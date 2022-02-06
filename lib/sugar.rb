# frozen_string_literal: true

module Sugar
  class << self
    attr_writer :redis

    def aws_s3?
      ENV["S3_BUCKET"] && ENV["S3_KEY_ID"] && ENV["S3_SECRET"] ? true : false
    end

    def redis
      @redis ||= Redis.new(driver: :hiredis, url: redis_url)
    end

    def redis_url=(new_url)
      @redis = nil
      @config = nil
      @redis_url = new_url
    end

    def redis_url
      @redis_url ||= "redis://127.0.0.1:6379/1"
    end

    def config(_key = nil, *_args)
      @config ||= Configuration.new.tap(&:load)
    end

    def public_browsing?
      config.public_browsing
    end
  end
end
