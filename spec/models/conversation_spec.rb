require "spec_helper"

describe Conversation do
  let(:conversation) { create(:conversation) }
  let(:user) { create(:user) }

  it do
    is_expected.to have_many(:conversation_relationships).dependent(:destroy)
  end

  it do
    is_expected.to have_many(:participants).through(:conversation_relationships)
  end

  it { is_expected.to be_kind_of(Exchange) }

  describe "after_create hook" do
    subject { conversation }
    specify { expect(subject.participants).to include(conversation.poster) }
  end

  describe "#add_participant" do
    context "with a new participant" do
      specify do
        expect do
          conversation.add_participant(user)
        end.to change { conversation.participants.count }.by(1)
      end
    end

    context "with an existing participant" do
      specify do
        expect do
          conversation.add_participant(conversation.poster)
        end.to change { conversation.participants.count }.by(0)
      end
    end
  end

  describe "#remove_participant" do
    context "with a second participant" do
      before { conversation.add_participant(user) }
      it do
        expect do
          conversation.remove_participant(user)
        end.to change { conversation.participants.count }.by(-1) end
    end

    context "with only one participant" do
      it "can't be removed" do
        expect do
          conversation.remove_participant(conversation.poster)
        end.to raise_exception(Conversation::RemoveParticipantError)
      end
    end
  end

  describe "#removeable?" do
    context "with a second participant" do
      before { conversation.add_participant(user) }
      subject { conversation.removeable?(user) }
      it { is_expected.to eq(true) }
    end

    context "with only one participant" do
      subject { conversation.removeable?(conversation.poster) }
      it { is_expected.to eq(false) }
    end
  end

  describe "#viewable_by?" do
    context "with a non-participant" do
      subject { conversation.viewable_by?(user) }
      it { is_expected.to eq(false) }
    end

    context "with a participant" do
      before { conversation.add_participant(user) }
      subject { conversation.viewable_by?(user) }
      it { is_expected.to eq(true) }
    end
  end

  describe "#editable_by?" do
    context "with a non-participant" do
      subject { conversation.editable_by?(user) }
      it { is_expected.to eq(false) }
    end

    context "with a participant" do
      before { conversation.add_participant(user) }
      subject { conversation.editable_by?(user) }
      it { is_expected.to eq(false) }
    end

    context "with the poster" do
      subject { conversation.editable_by?(conversation.poster) }
      it { is_expected.to eq(true) }
    end
  end

  describe "#postable_by?" do
    context "non-participant" do
      subject { conversation.postable_by?(user) }
      it { is_expected.to eq(false) }
    end

    context "participant" do
      before { conversation.add_participant(user) }
      subject { conversation.postable_by?(user) }
      it { is_expected.to eq(true) }
    end
  end

  describe "#closeable_by?" do
    specify do
      expect(conversation.closeable_by?(conversation.poster)).to eq(false)
    end
  end
end
