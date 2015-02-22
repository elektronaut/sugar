# encoding: utf-8

require_relative "sugar/responder"

module Sugar
  class << self
    attr_accessor :redis

    def aws_s3?
      (config.amazon_aws_key && config.amazon_aws_secret && config.amazon_s3_bucket) ? true : false
    end

    def redis
      @redis ||= Redis.new(driver: :hiredis)
    end

    def config(_key = nil, *_args)
      @config ||= Configuration.new.tap { |c| c.load }
    end

    def public_browsing?
      config.public_browsing
    end
  end
end
