require "spec_helper"

describe DiscussionView do
  it { should belong_to(:user) }
  it { should belong_to(:discussion) }
  it { should belong_to(:post) }
end