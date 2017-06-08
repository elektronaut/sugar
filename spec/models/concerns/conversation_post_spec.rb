# encoding: utf-8

require "rails_helper"

describe ConversationPost do
  let(:discussion) { create(:discussion) }
  let(:conversation) { create(:conversation) }

  describe "#flag_conversation" do
    subject { post }

    context "when in a conversation" do
      let(:post) { create(:post, exchange: conversation) }
      specify { expect(subject.conversation?).to eq(true) }
    end

    context "when in a regular discussion" do
      let(:post) { create(:post, exchange: discussion) }
      specify { expect(subject.conversation?).to eq(false) }
    end
  end
end
