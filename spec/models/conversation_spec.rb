require 'spec_helper'

describe Conversation do
  it { should have_many :conversation_relationships }
  it { should have_many :participants }

  let(:conversation) { create(:conversation) }
  let(:user) { create(:user) }

  it 'inherits from Exchange' do
    conversation.should be_kind_of(Exchange)
  end

  it 'has the poster as a participant' do
    conversation.participants.should include(conversation.poster)
  end

  it 'can add participants' do
    conversation.add_participant(user)
    conversation.participants.count.should eq(2)
    conversation.participants.should include(user)
  end

  it 'can remove participants' do
    conversation.add_participant(user)
    conversation.remove_participant(user)
    conversation.participants.count.should eq(1)
    conversation.participants.should_not include(user)
  end

  it 'cannot remove the last participant' do
    conversation.add_participant(user)
    conversation.remove_participant(conversation.poster)
    expect {
      conversation.remove_participant(user)
    }.to raise_exception(Sugar::Exceptions::RemoveParticipantError)
  end

end
