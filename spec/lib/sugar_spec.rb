require 'spec_helper'

describe Sugar, redis: true do
  # Reload config before each run
  before { Sugar.load_config! }

  it "has access to redis" do
    Sugar.redis.should_not be_nil
  end

  describe 'configuration' do
    it "has a default configuration" do
      Sugar.config(:forum_name).should == 'Sugar'
    end

    it "should be configurable" do
      Sugar.config(:forum_name, 'My Forum')
      Sugar.save_config!
      Sugar.load_config!
      Sugar.config(:forum_name).should == 'My Forum'
    end
  end
end