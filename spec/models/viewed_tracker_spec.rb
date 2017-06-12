# encoding: utf-8

require "rails_helper"

describe ViewedTracker do
  let(:user) { create(:user) }
  let(:tracker) { ViewedTracker.new(user) }
  let(:discussion) { create(:discussion) }
  let(:read_discussion) do
    discussion = create(:discussion)
    ExchangeView.create(
      user: user,
      exchange: discussion,
      post_index: 1,
      post: discussion.posts.last
    )
    discussion
  end
  let(:partially_read_discussion) do
    discussion = create(:discussion)
    ExchangeView.create(
      user: user, exchange: discussion, post_index: 64,
      post: discussion.posts.last
    )
    allow(discussion).to receive(:posts_count).and_return(105)
    discussion
  end
  let(:discussion_with_post) {}
  let(:exchanges) { [discussion] }

  describe "#any?" do
    subject { tracker.any? }

    context "without exchanges" do
      it { is_expected.to eq(false) }
    end

    context "with exchanges" do
      before { tracker.exchanges = exchanges }

      context "with user" do
        it { is_expected.to eq(true) }
      end

      context "without user" do
        let(:user) { nil }
        it { is_expected.to eq(false) }
      end
    end
  end

  describe "#last_page" do
    before { tracker.exchanges = exchanges }
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
      it "should return the last page" do
        expect(discussion).to receive(:last_page).and_return(15)
        expect(tracker.last_page(discussion)).to eq(15)
      end
    end
  end

  describe "#last_post_id" do
    subject { tracker.last_post_id(discussion) }

    context "with no exchanges" do
      it { is_expected.to eq(nil) }
    end

    context "with exchanges" do
      before { tracker.exchanges = exchanges }

      context "and no user" do
        let(:user) { nil }
        it { is_expected.to eq(nil) }
      end

      context "but no view" do
        it { is_expected.to eq(nil) }
      end

      context "and a view" do
        let(:discussion) { read_discussion }
        it { is_expected.to eq(read_discussion.posts.last.id) }
      end
    end
  end

  describe "#last_post_id?" do
    subject { tracker.last_post_id?(discussion) }

    context "with no exchanges" do
      it { is_expected.to eq(false) }
    end

    context "with exchanges" do
      before { tracker.exchanges = exchanges }

      context "and no user" do
        let(:user) { nil }
        it { is_expected.to eq(false) }
      end

      context "but no view" do
        it { is_expected.to eq(false) }
      end

      context "and a view" do
        let(:discussion) { read_discussion }
        it { is_expected.to eq(true) }
      end
    end
  end

  describe "#new_posts" do
    subject { tracker.new_posts(discussion) }

    context "with no exchanges" do
      it { is_expected.to eq(0) }
    end

    context "with exchanges" do
      before { tracker.exchanges = exchanges }

      context "and no user" do
        let(:user) { nil }
        it { is_expected.to eq(0) }
      end

      context "but no view" do
        it { is_expected.to eq(1) }
      end

      context "and a view" do
        let(:discussion) { partially_read_discussion }
        it { is_expected.to eq(105 - 64) }
      end
    end
  end

  describe "#new_posts?" do
    subject { tracker.new_posts?(discussion) }

    context "with no exchanges" do
      it { is_expected.to eq(false) }
    end

    context "with exchanges" do
      before { tracker.exchanges = exchanges }

      context "and no user" do
        let(:user) { nil }
        it { is_expected.to eq(false) }
      end

      context "haven't been opened" do
        it { is_expected.to eq(true) }
      end

      context "when discussion is fully read" do
        let(:discussion) { read_discussion }
        it { is_expected.to eq(false) }
      end

      context "when discussion is partially read" do
        let(:discussion) { partially_read_discussion }
        it { is_expected.to eq(true) }
      end
    end
  end
end
