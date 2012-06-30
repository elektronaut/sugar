require 'spec_helper'

describe Sugar, :redis => true do
  before do
    Sugar.redis = redis
  end

  it "has access to redis" do
    Sugar.redis.should_not be_nil
  end
end