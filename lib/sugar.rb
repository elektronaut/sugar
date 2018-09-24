# frozen_string_literal: true

module Sugar
  class << self
    attr_writer :redis

    def aws_s3?
      if config.amazon_aws_key &&
         config.amazon_aws_secret &&
         config.amazon_s3_bucket
        true
      else
        false
      end
    end

    def redis
      @redis ||= Redis.new(driver: :hiredis)
    end

    def config(_key = nil, *_args)
      @config ||= Configuration.new.tap(&:load)
    end

    def public_browsing?
      config.public_browsing
    end
  end
end
