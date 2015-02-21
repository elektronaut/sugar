require 'spec_helper'

describe Sugar, redis: true do
  # Reload config before each run
  before { Sugar.config.load }

  it "has access to redis" do
    expect(Sugar.redis).not_to eq(nil)
  end
end
