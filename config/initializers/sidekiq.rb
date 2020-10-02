# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/1") }
end

ActiveJob::Base.queue_adapter = :sidekiq
