require "spec_helper"

describe ExchangeView do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:exchange) }
  it { is_expected.to belong_to(:post) }
end
