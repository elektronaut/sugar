# frozen_string_literal: true

class ImportSettingsFromRedis < ActiveRecord::Migration[7.1]
  def up
    redis_config.each do |name, value|
      Setting.find_or_initialize_by(name:).update(value:)
    end
  end

  private

  def redis
    @redis ||= Redis.new(
      driver: :hiredis,
      url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/1")
    )
  end

  def redis_config
    saved_config = redis.get("configuration")
    return {} unless saved_config

    JSON.parse(saved_config).symbolize_keys
  end
end
