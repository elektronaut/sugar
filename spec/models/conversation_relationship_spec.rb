require 'spec_helper'

describe ConversationRelationship do
  before { create(:conversation_relationship) }

  it { should belong_to(:user) }
  it { should belong_to(:conversation) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:conversation_id) }
end