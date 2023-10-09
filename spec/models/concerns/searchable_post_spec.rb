# frozen_string_literal: true

require "rails_helper"

describe SearchablePost, :solr do
  around do |each|
    perform_enqueued_jobs do
      each.run
    end
  end

  describe ".search_results" do
    let(:exchange) { create(:discussion, body: "testing discussion") }
    let!(:post) { create(:post, body: "testing post") }
    let!(:exchange_post) { exchange.posts.first }
    let(:user) { create(:user) }

    before do
      Sunspot.commit
    end

    describe "searching all posts when logged in as nobody" do
      subject { Post.search_results("testing", user: nil, page: 1) }

      it { is_expected.to contain_exactly(post, exchange_post) }
    end

    describe "searching all posts when logged in as a regular user" do
      subject { Post.search_results("testing", user: user, page: 1) }

      it { is_expected.to contain_exactly(post, exchange_post) }
    end

    describe "searching in a discussion when logged in as nobody" do
      subject do
        Post.search_results(
          "testing", user: nil, page: 1, exchange: exchange
        )
      end

      it { is_expected.to contain_exactly(exchange_post) }
    end

    describe "searching in a discussion when logged in as a regular user" do
      subject do
        Post.search_results(
          "testing", user: user, page: 1, exchange: exchange
        )
      end

      it { is_expected.to contain_exactly(exchange_post) }
    end

    describe "searching in a conversation" do
      subject do
        Post.search_results(
          "testing", user: user, page: 1, exchange: exchange
        )
      end

      let(:exchange) { create(:conversation, body: "testing conversation") }
      let!(:exchange_post) { exchange.posts.first }

      it { is_expected.to contain_exactly(exchange_post) }
    end
  end
end
