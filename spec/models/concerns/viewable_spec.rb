# frozen_string_literal: true

require "rails_helper"

describe Viewable do
  let(:discussion) { create(:discussion) }
  let(:trusted_discussion) { create(:discussion, trusted: true) }
  let(:user) { create(:user) }
  let(:trusted_user) { create(:trusted_user) }

  describe ".viewable_by" do
    before do
      discussion
      trusted_discussion
    end

    subject { Discussion.viewable_by(user) }

    context "when user is trusted" do
      let(:user) { create(:trusted_user) }

      it { is_expected.to match_array([discussion, trusted_discussion]) }
    end

    context "when user isn't trusted" do
      let(:user) { create(:user) }

      it { is_expected.to match_array([discussion]) }
    end
  end

  describe "#viewable_by?" do
    specify do
      expect(trusted_discussion.viewable_by?(trusted_user)).to eq(true)
    end

    specify { expect(trusted_discussion.viewable_by?(user)).to eq(false) }
    specify { expect(trusted_discussion.viewable_by?(nil)).to eq(false) }

    context "when public browsing is on" do
      before { configure public_browsing: true }
      specify { expect(discussion.viewable_by?(user)).to eq(true) }
      specify { expect(discussion.viewable_by?(nil)).to eq(true) }
    end

    context "when public browsing is off" do
      before { configure public_browsing: false }
      specify { expect(discussion.viewable_by?(user)).to eq(true) }
      specify { expect(discussion.viewable_by?(nil)).to eq(false) }
    end
  end
end
