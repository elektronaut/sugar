# frozen_string_literal: true

require "rails_helper"

describe ConversationRelationship do
  before { create(:conversation_relationship) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:conversation) }

  specify do
    expect(described_class.new).to(
      validate_uniqueness_of(:user_id).scoped_to(:conversation_id)
    )
  end
end
