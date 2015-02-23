# encoding: utf-8

require "spec_helper"

describe ExchangeParticipant do
  let(:user)         { create(:user) }
  let(:discussion)   { create(:discussion) }
  let(:conversation) { create(:conversation) }

  subject { user }

  it { is_expected.to have_many(:discussions) }
  it { is_expected.to have_many(:posts) }
  it { is_expected.to have_many(:discussion_posts).class_name("Post") }
  it { is_expected.to have_many(:exchange_views).dependent(:destroy) }
  it { is_expected.to have_many(:discussion_relationships).dependent(:destroy) }

  it do
    is_expected.to have_many(:conversation_relationships).
      dependent(:destroy)
  end

  it do
    is_expected.to have_many(:conversations).
      through(:conversation_relationships)
  end

  describe "#mark_exchange_viewed" do
    let(:post) { create(:post, exchange: discussion) }

    context "with existing exchange view" do
      let!(:exchange_view) do
        create(:exchange_view, user: user, exchange: discussion)
      end

      it "does not create a new view" do
        expect do
          user.mark_exchange_viewed(discussion, post, 2)
        end.to change { ExchangeView.count }.by(0)
      end

      describe "the new view" do
        before do
          user.mark_exchange_viewed(discussion, post, 2)
          exchange_view.reload
        end

        subject { exchange_view }
        specify { expect(subject.post_index).to eq(2) }
        specify { expect(subject.post).to eq(post) }
      end
    end

    context "without existing discussion view" do
      it "creates a new view" do
        expect do
          user.mark_exchange_viewed(discussion, post, 2)
        end.to change { ExchangeView.count }.by(1)
      end

      describe "the new discussion view" do
        before { user.mark_exchange_viewed(discussion, post, 2) }
        subject { user.exchange_views.last }
        specify { expect(subject.post_index).to eq(2) }
        specify { expect(subject.post).to eq(post) }
      end
    end
  end

  describe "#mark_conversation_viewed" do
    let(:user)         { conversation.poster }
    let(:conversation_relationship) do
      user.conversation_relationships.where(conversation_id: conversation).first
    end
    before { conversation_relationship.update_attributes(new_posts: true) }
    before { user.mark_conversation_viewed(conversation) }
    subject do
      user.conversation_relationships.where(conversation_id: conversation).first
    end
    specify { expect(subject.new_posts?).to eq(false) }
  end

  describe "#posts_per_day" do
    let(:user) { create(:user, created_at: 3.days.ago) }

    before do
      create(:post, user: user)
      user.reload
    end

    subject { user.posts_per_day }

    it { is_expected.to be_within(0.001).of(1.0 / 3.0) }
  end

  describe "#unread_conversations_count" do
    subject { user.unread_conversations_count }

    context "with no conversations" do
      it { is_expected.to eq(0) }
    end

    context "when notifications is set to false" do
      before do
        create(
          :conversation_relationship,
          user: user,
          new_posts: true,
          notifications: false
        )
      end

      it { is_expected.to eq(0) }
    end

    context "when notifications is set to false" do
      before do
        create(
          :conversation_relationship,
          user: user,
          new_posts: true,
          notifications: true
        )
      end

      it { is_expected.to eq(1) }
    end
  end

  describe "#unread_conversations?" do
    subject { user.unread_conversations? }

    context "with no unread conversations" do
      it { is_expected.to eq(false) }
    end

    context "with unread conversations" do
      before do
        create(
          :conversation_relationship,
          user: user,
          new_posts: true,
          notifications: true
        )
      end

      it { is_expected.to eq(true) }
    end
  end

  describe "#following?" do
    subject { user.following?(discussion) }

    context "when discussion isn't followed" do
      it { is_expected.to eq(false) }
    end

    context "when discussion is followed" do
      before do
        DiscussionRelationship.define(user, discussion, following: true)
      end

      it { is_expected.to eq(true) }
    end
  end

  describe "#favorite?" do
    subject { user.favorite?(discussion) }

    context "when discussion isn't favorite" do
      it { is_expected.to eq(false) }
    end

    context "when discussion is favorite" do
      before { DiscussionRelationship.define(user, discussion, favorite: true) }
      it { is_expected.to eq(true) }
    end
  end
end
