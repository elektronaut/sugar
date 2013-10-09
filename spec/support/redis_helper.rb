module RedisHelper

  CONFIG = { url: "redis://127.0.0.1:6379/2" }

  def redis
    @redis ||= ::Redis.connect(CONFIG)
  end

  def with_watch(redis, *args)
    redis.watch( *args )
    begin
      yield
    ensure
      redis.unwatch
    end
  end

  def with_clean_redis(&block)
    redis.client.disconnect
    redis.flushdb
    begin
      yield
    ensure
      redis.flushdb
      redis.quit
    end
  end

end
