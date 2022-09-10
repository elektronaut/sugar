# frozen_string_literal: true

require "rails_helper"

describe Viewable do
  let(:discussion) { create(:discussion) }
  let(:user) { create(:user) }

  describe ".viewable_by" do
    subject { Discussion.viewable_by(user) }

    before do
      discussion
    end

    it { is_expected.to match_array([discussion]) }
  end

  describe "#viewable_by?" do
    context "when public browsing is on" do
      before { configure public_browsing: true }

      specify { expect(discussion.viewable_by?(user)).to be(true) }
      specify { expect(discussion.viewable_by?(nil)).to be(true) }
    end

    context "when public browsing is off" do
      before { configure public_browsing: false }

      specify { expect(discussion.viewable_by?(user)).to be(true) }
      specify { expect(discussion.viewable_by?(nil)).to be(false) }
    end
  end
end
