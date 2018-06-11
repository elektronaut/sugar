# frozen_string_literal: true

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # We're in smart spawning mode.
    if forked
      # Re-establish redis connection
      require "redis"

      # The important two lines
      Sugar.redis.client.disconnect
      Sugar.redis = Redis.new
    end
  end
end
