# frozen_string_literal: true

require "rails_helper"

describe Discussion do
  # Create the first admin user
  before { create(:user) }

  let(:discussion) { create(:discussion) }

  it { is_expected.to have_many(:discussion_relationships).dependent(:destroy) }
  it { is_expected.to be_a(Exchange) }

  describe ".popular_in_the_last" do
    let(:discussion1) { create(:discussion) }
    let(:discussion2) { create(:discussion) }

    before do
      discussion1.posts.first.update(created_at: 4.days.ago)
      [13.days.ago, 12.days.ago].each do |t|
        create(:post, exchange: discussion1, created_at: t)
      end
      [2.days.ago].each do |t|
        create(:post, exchange: discussion2, created_at: t)
      end
    end

    context "when within the last 3 days" do
      subject { described_class.popular_in_the_last(3.days) }

      it { is_expected.to eq([discussion2]) }
    end

    context "when within the last 7 days" do
      subject { described_class.popular_in_the_last(7.days) }

      before do
        discussion1
        discussion2
      end

      it { is_expected.to eq([discussion2, discussion1]) }
    end

    context "when within the last 14 days" do
      subject { described_class.popular_in_the_last(14.days) }

      it { is_expected.to eq([discussion1, discussion2]) }
    end
  end

  describe "#convert_to_conversation!" do
    let!(:post) { create(:post, exchange: discussion) }
    let(:conversation) { Conversation.find(discussion.id) }

    before { discussion.convert_to_conversation! }

    specify { expect(discussion.type).to eq("Conversation") }
    specify { expect(post.reload.conversation?).to be(true) }

    specify do
      expect(
        DiscussionRelationship.where(discussion_id: discussion.id).count
      ).to eq(0)
    end

    specify do
      expect(
        ConversationRelationship.where(conversation_id: discussion.id).count
      ).to eq(2)
    end

    specify do
      expect(
        conversation.participants
      ).to match_array([discussion.poster, post.user])
    end
  end

  describe "#participants" do
    subject { discussion.participants }

    let!(:post) { create(:post, exchange: discussion) }

    it { is_expected.to match_array([discussion.poster, post.user]) }
  end

  describe "#viewable_by?" do
    context "when public browsing is on" do
      before { Sugar.config.public_browsing = true }

      specify { expect(discussion.viewable_by?(nil)).to be(true) }
    end

    context "when public browsing is off" do
      before { Sugar.config.public_browsing = false }

      specify { expect(discussion.viewable_by?(nil)).to be(false) }
      specify { expect(discussion.viewable_by?(create(:user))).to be(true) }
    end
  end

  describe "#editable_by?" do
    let(:exchange_moderator) do
      create(:exchange_moderator, exchange: discussion).user
    end
    let(:user_admin) { create(:user_admin) }

    specify { expect(discussion.editable_by?(discussion.poster)).to be(true) }
    specify { expect(discussion.editable_by?(create(:user))).to be(false) }
    specify { expect(discussion.editable_by?(create(:moderator))).to be(true) }
    specify { expect(discussion.editable_by?(exchange_moderator)).to be(true) }
    specify { expect(discussion.editable_by?(create(:admin))).to be(true) }
    specify { expect(discussion.editable_by?(user_admin)).to be(false) }
    specify { expect(discussion.editable_by?(nil)).to be(false) }
  end

  describe "#postable_by?" do
    let(:user) { create(:user) }

    context "when not closed" do
      specify { expect(discussion.postable_by?(user)).to be(true) }
      specify { expect(discussion.postable_by?(nil)).to be(false) }
    end

    context "when closed" do
      let(:discussion) { create(:discussion, closed: true) }

      specify { expect(discussion.postable_by?(user)).to be(false) }

      specify do
        expect(
          discussion.postable_by?(discussion.poster)
        ).to be(false)
      end

      specify do
        expect(discussion.postable_by?(create(:moderator))).to be(true)
      end

      specify { expect(discussion.postable_by?(create(:admin))).to be(true) }
    end
  end
end
