require 'spec_helper'

describe Sugar, redis: true do
  # Reload config before each run
  before { Sugar.config.load }

  it "has access to redis" do
    Sugar.redis.should_not be_nil
  end
end