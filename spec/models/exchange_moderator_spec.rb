require "rails_helper"

RSpec.describe ExchangeModerator, type: :model do
  subject { build(:exchange_moderator) }

  it { is_expected.to belong_to(:exchange) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:exchange_id) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:exchange_id) }
end
