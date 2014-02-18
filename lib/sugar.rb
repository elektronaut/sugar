# encoding: utf-8

require_relative "sugar/responder"

module Sugar

  class << self
    attr_accessor :redis

    def aws_s3?
      (self.config.amazon_aws_key && self.config.amazon_aws_secret && self.config.amazon_s3_bucket) ? true : false
    end

    def redis
      @redis ||= Redis.new(driver: :hiredis)
    end

    def config(key=nil, *args)
      @config ||= Configuration.new.tap{ |c| c.load }
    end

    def public_browsing?
      self.config.public_browsing
    end
  end
end
