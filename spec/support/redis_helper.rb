# frozen_string_literal: true

module RedisHelper
  CONFIG = { url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/2") }.freeze

  def redis
    @redis ||= ::Redis.new(CONFIG)
  end

  def with_watch(redis, *)
    redis.watch(*)
    begin
      yield
    ensure
      redis.unwatch
    end
  end

  def with_clean_redis(&)
    redis.flushdb
    begin
      yield
    ensure
      redis.flushdb
    end
  end
end
