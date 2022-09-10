# frozen_string_literal: true

require "rails_helper"

describe ConversationPost do
  let(:discussion) { create(:discussion) }
  let(:conversation) { create(:conversation) }

  describe "#flag_conversation" do
    subject { post.conversation? }

    context "when in a conversation" do
      let(:post) { create(:post, exchange: conversation) }

      it { is_expected.to be(true) }
    end

    context "when in a regular discussion" do
      let(:post) { create(:post, exchange: discussion) }

      it { is_expected.to be(false) }
    end
  end
end
