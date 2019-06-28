# frozen_string_literal: true

require "rails_helper"

describe SearchablePost, solr: true do
  let(:discussion) { create(:discussion, body: "testing discussion") }
  let(:conversation) { create(:conversation, body: "testing conversation") }
  let!(:post) { create(:post, body: "testing post") }
  let!(:discussion_post) { discussion.posts.first }
  let!(:conversation_post) { conversation.posts.first }
  let(:user) { create(:user) }

  describe ".search_results" do
    before { Sunspot.commit }

    describe "searching all posts when logged in as nobody" do
      subject { Post.search_results("testing", user: nil, page: 1) }

      it { is_expected.to match_array([post, discussion_post]) }
    end

    describe "searching all posts when logged in as a regular user" do
      subject { Post.search_results("testing", user: user, page: 1) }

      it { is_expected.to match_array([post, discussion_post]) }
    end

    describe "searching in a discussion when logged in as nobody" do
      subject do
        Post.search_results(
          "testing", user: nil, page: 1, exchange: discussion
        )
      end

      it { is_expected.to match_array([discussion_post]) }
    end

    describe "searching in a discussion when logged in as a regular user" do
      subject do
        Post.search_results(
          "testing", user: user, page: 1, exchange: discussion
        )
      end

      it { is_expected.to match_array([discussion_post]) }
    end

    describe "searching in a conversation" do
      subject do
        Post.search_results(
          "testing", user: user, page: 1, exchange: conversation
        )
      end

      it { is_expected.to match_array([conversation_post]) }
    end
  end
end
