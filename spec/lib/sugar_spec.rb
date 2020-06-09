# frozen_string_literal: true

require "rails_helper"

describe Sugar, redis: true do
  # Reload config before each run
  before { described_class.config.load }

  it "has access to redis" do
    expect(described_class.redis).not_to eq(nil)
  end
end
