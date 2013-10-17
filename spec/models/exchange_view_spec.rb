require "spec_helper"

describe ExchangeView do
  it { should belong_to(:user) }
  it { should belong_to(:exchange) }
  it { should belong_to(:post) }
end