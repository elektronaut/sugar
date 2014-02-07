# encoding: utf-8

require_relative "sugar/responder"
require_relative "sugar/configuration"

module Sugar

  class << self
    attr_accessor :redis

    def aws_s3?
      (self.config(:amazon_aws_key) && self.config(:amazon_aws_secret) && self.config(:amazon_s3_bucket)) ? true : false
    end

    def redis
      @redis ||= Redis.new
    end

    def config(key=nil, *args)
      @config ||= Sugar::Configuration.new.tap{ |c| c.load }
      if key
        @config.send(key, *args)
      else
        @config
      end
    end

    def public_browsing?
      self.config(:public_browsing)
    end
  end
end
