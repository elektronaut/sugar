require 'spec_helper'

describe Conversation do
  let(:conversation) { create(:conversation) }
  let(:user) { create(:user) }

  it { should have_many(:conversation_relationships).dependent(:destroy) }
  it { should have_many(:participants).through(:conversation_relationships) }

  it { should be_kind_of(Exchange) }

  describe "after_create hook" do
    subject { conversation }
    its(:participants) { should include(conversation.poster) }
  end

  describe "#add_participant" do
    context "new participant" do
      it { expect {
        conversation.add_participant(user)
      }.to change{ conversation.participants.count }.by(1) }
    end
    context "existing participant" do
      it { expect {
        conversation.add_participant(conversation.poster)
      }.to change{ conversation.participants.count }.by(0) }
    end
  end

  describe "#remove_participant" do
    context "second participant" do
      before { conversation.add_participant(user) }
      it { expect {
        conversation.remove_participant(user)
      }.to change{ conversation.participants.count }.by(-1) }
    end
    context "last participant" do
      it "can't be removed" do
        expect {
          conversation.remove_participant(conversation.poster)
        }.to raise_exception(Sugar::Exceptions::RemoveParticipantError)
      end
    end
  end

  describe "#removeable?" do
    context "second participant" do
      before { conversation.add_participant(user) }
      subject { conversation.removeable?(user) }
      it { should be_true }
    end
    context "last participant" do
      subject { conversation.removeable?(conversation.poster) }
      it { should be_false }
    end
  end

  describe "#viewable_by?" do
    context "non-participant" do
      subject { conversation.viewable_by?(user) }
      it { should be_false }
    end
    context "participant" do
      before { conversation.add_participant(user) }
      subject { conversation.viewable_by?(user) }
      it { should be_true }
    end
  end

  describe "#editable_by?" do
    context "non-participant" do
      subject { conversation.editable_by?(user) }
      it { should be_false }
    end
    context "participant" do
      before { conversation.add_participant(user) }
      subject { conversation.editable_by?(user) }
      it { should be_false }
    end
    context "poster" do
      subject { conversation.editable_by?(conversation.poster) }
      it { should be_true }
    end
  end

  describe "#postable_by?" do
    context "non-participant" do
      subject { conversation.postable_by?(user) }
      it { should be_false }
    end
    context "participant" do
      before { conversation.add_participant(user) }
      subject { conversation.postable_by?(user) }
      it { should be_true }
    end
  end

  describe "#closeable_by?" do
    subject { conversation.closeable_by?(conversation.poster) }
    it { should be_false }
  end

end
