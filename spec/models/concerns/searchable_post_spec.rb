# frozen_string_literal: true

require "rails_helper"

describe SearchablePost do
  let(:exchange) { create(:discussion, body: "testing discussion") }
  let!(:post) { create(:post, body: "testing post") }
  let!(:exchange_post) { exchange.posts.first }
  let(:user) { create(:user) }

  describe ".search" do
    subject { Post.search("testing") }

    it { is_expected.to contain_exactly(post, exchange_post) }
  end

  describe ".search_in_exchange" do
    subject { exchange.posts.search_in_exchange("testing") }

    it { is_expected.to contain_exactly(exchange_post) }

    context "when exchange is a conversation" do
      let(:exchange) { create(:conversation, body: "testing conversation") }

      it { is_expected.to contain_exactly(exchange_post) }
    end
  end
end
