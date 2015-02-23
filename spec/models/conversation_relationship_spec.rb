require "spec_helper"

describe ConversationRelationship do
  before { create(:conversation_relationship) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:conversation) }

  it do
    is_expected.to validate_uniqueness_of(:user_id).scoped_to(:conversation_id)
  end
end
