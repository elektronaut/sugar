require 'spec_helper'

describe Sugar, :redis => true do
  before do
    # Reset Redis settings to default
    Sugar.redis = redis
    Sugar.redis_prefix = 'sugar'
  end

  it "has access to redis" do
    Sugar.redis.should_not be_nil
  end

  it "has a default redis prefix" do
    Sugar.redis_prefix.should == 'sugar'
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