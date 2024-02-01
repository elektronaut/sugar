# frozen_string_literal: true

require "rails_helper"

describe ViewedTracker do
  let(:user) { create(:user) }
  let(:tracker) { described_class.new(user) }
  let(:discussion) { create(:discussion) }
  let(:read_discussion) do
    discussion = create(:discussion)
    ExchangeView.create(
      user:,
      exchange: discussion,
      post_index: 1,
      post: discussion.posts.last
    )
    discussion
  end
  let(:partially_read_discussion) do
    discussion = create(:discussion)
    ExchangeView.create(
      user:, exchange: discussion, post_index: 64,
      post: discussion.posts.last
    )
    allow(discussion).to receive(:posts_count).and_return(105)
    discussion
  end

  before { tracker.exchanges = [discussion] }

  describe "#any?" do
    subject { tracker.any? }

    context "without exchanges" do
      before { tracker.exchanges = [] }

      it { is_expected.to be(false) }
    end

    context "with user" do
      it { is_expected.to be(true) }
    end

    context "without user" do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end
  end

  describe "#last_page" do
    subject { tracker.last_page(discussion) }

    context "without user" do
      let(:user) { nil }

      it { is_expected.to eq(1) }
    end

    context "when discussion is unread" do
      it { is_expected.to eq(1) }
    end

    context "when discussion is partially read" do
      let(:discussion) { partially_read_discussion }

      it { is_expected.to eq(2) }
    end

    context "when there are no new posts" do
      let(:discussion) { read_discussion }

      it "returns the last page" do
        allow(discussion).to receive(:last_page).and_return(15)
        expect(tracker.last_page(discussion)).to eq(15)
      end
    end
  end

  describe "#last_post_id" do
    subject { tracker.last_post_id(discussion) }

    context "with no exchanges" do
      before { tracker.exchanges = [] }

      it { is_expected.to be_nil }
    end

    context "when no user" do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end

    context "without any view" do
      it { is_expected.to be_nil }
    end

    context "with a view" do
      let(:discussion) { read_discussion }

      it { is_expected.to eq(read_discussion.posts.last.id) }
    end
  end

  describe "#last_post_id?" do
    subject { tracker.last_post_id?(discussion) }

    context "with no exchanges" do
      before { tracker.exchanges = [] }

      it { is_expected.to be(false) }
    end

    context "without user" do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end

    context "without view" do
      it { is_expected.to be(false) }
    end

    context "with a view" do
      let(:discussion) { read_discussion }

      it { is_expected.to be(true) }
    end
  end

  describe "#new_posts" do
    subject { tracker.new_posts(discussion) }

    context "with no exchanges" do
      before { tracker.exchanges = [] }

      it { is_expected.to eq(0) }
    end

    context "without user" do
      let(:user) { nil }

      it { is_expected.to eq(0) }
    end

    context "without view" do
      it { is_expected.to eq(1) }
    end

    context "with a view" do
      let(:discussion) { partially_read_discussion }

      it { is_expected.to eq(105 - 64) }
    end
  end

  describe "#new_posts?" do
    subject { tracker.new_posts?(discussion) }

    context "with no exchanges" do
      before { tracker.exchanges = [] }

      it { is_expected.to be(false) }
    end

    context "without user" do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end

    context "when unopened" do
      it { is_expected.to be(true) }
    end

    context "when discussion is fully read" do
      let(:discussion) { read_discussion }

      it { is_expected.to be(false) }
    end

    context "when discussion is partially read" do
      let(:discussion) { partially_read_discussion }

      it { is_expected.to be(true) }
    end
  end
end
